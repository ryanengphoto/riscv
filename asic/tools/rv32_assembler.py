#!/usr/bin/env python3
"""
RV32I + Zbb Assembler for Testbench Generation
Converts assembly instructions to Verilog instruction_mem assignments

Usage:
    python rv32_assembler.py input.s > output.svh
    python rv32_assembler.py -i "add x1, x2, x3"
    
Supported instructions:
    RV32I: add, sub, and, or, xor, sll, srl, sra, slt, sltu
           addi, andi, ori, xori, slti, sltiu, slli, srli, srai
           lw, sw, lb, sb, lh, sh, lbu, lhu
           beq, bne, blt, bge, bltu, bgeu
           jal, jalr
           lui, auipc
           nop (pseudo)
    Zbb:  andn, orn, xnor, min, max, minu, maxu
          clz, ctz, cpop, sext.b, sext.h, zext.h
          rol, ror, rori, orc.b, rev8
"""

import sys
import re
import argparse

# Register name to number mapping
REGS = {
    'x0': 0, 'zero': 0,
    'x1': 1, 'ra': 1,
    'x2': 2, 'sp': 2,
    'x3': 3, 'gp': 3,
    'x4': 4, 'tp': 4,
    'x5': 5, 't0': 5,
    'x6': 6, 't1': 6,
    'x7': 7, 't2': 7,
    'x8': 8, 's0': 8, 'fp': 8,
    'x9': 9, 's1': 9,
    'x10': 10, 'a0': 10,
    'x11': 11, 'a1': 11,
    'x12': 12, 'a2': 12,
    'x13': 13, 'a3': 13,
    'x14': 14, 'a4': 14,
    'x15': 15, 'a5': 15,
    'x16': 16, 'a6': 16,
    'x17': 17, 'a7': 17,
    'x18': 18, 's2': 18,
    'x19': 19, 's3': 19,
    'x20': 20, 's4': 20,
    'x21': 21, 's5': 21,
    'x22': 22, 's6': 22,
    'x23': 23, 's7': 23,
    'x24': 24, 's8': 24,
    'x25': 25, 's9': 25,
    'x26': 26, 's10': 26,
    'x27': 27, 's11': 27,
    'x28': 28, 't3': 28,
    'x29': 29, 't4': 29,
    'x30': 30, 't5': 30,
    'x31': 31, 't6': 31,
}

def reg(name):
    """Convert register name to number"""
    name = name.strip().lower()
    if name not in REGS:
        raise ValueError(f"Unknown register: {name}")
    return REGS[name]

def imm(val, bits, signed=True):
    """Parse and validate immediate value"""
    if isinstance(val, str):
        val = val.strip()
        if val.startswith('0x') or val.startswith('-0x'):
            val = int(val, 16)
        elif val.startswith('0b'):
            val = int(val, 2)
        else:
            val = int(val)
    
    if signed:
        min_val = -(1 << (bits - 1))
        max_val = (1 << (bits - 1)) - 1
    else:
        min_val = 0
        max_val = (1 << bits) - 1
    
    if val < min_val or val > max_val:
        raise ValueError(f"Immediate {val} out of range [{min_val}, {max_val}]")
    
    if val < 0:
        val = val & ((1 << bits) - 1)
    
    return val

def encode_r_type(opcode, rd, funct3, rs1, rs2, funct7):
    """Encode R-type instruction"""
    return (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def encode_i_type(opcode, rd, funct3, rs1, imm12):
    """Encode I-type instruction"""
    imm12 = imm12 & 0xFFF
    return (imm12 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode

def encode_s_type(opcode, funct3, rs1, rs2, imm12):
    """Encode S-type instruction"""
    imm12 = imm12 & 0xFFF
    imm_11_5 = (imm12 >> 5) & 0x7F
    imm_4_0 = imm12 & 0x1F
    return (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode

def encode_b_type(opcode, funct3, rs1, rs2, imm13):
    """Encode B-type instruction (branch)"""
    imm13 = imm13 & 0x1FFF
    imm_12 = (imm13 >> 12) & 0x1
    imm_11 = (imm13 >> 11) & 0x1
    imm_10_5 = (imm13 >> 5) & 0x3F
    imm_4_1 = (imm13 >> 1) & 0xF
    return (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | \
           (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode

def encode_u_type(opcode, rd, imm20):
    """Encode U-type instruction"""
    return (imm20 << 12) | (rd << 7) | opcode

def encode_j_type(opcode, rd, imm21):
    """Encode J-type instruction (JAL)"""
    imm21 = imm21 & 0x1FFFFF
    imm_20 = (imm21 >> 20) & 0x1
    imm_19_12 = (imm21 >> 12) & 0xFF
    imm_11 = (imm21 >> 11) & 0x1
    imm_10_1 = (imm21 >> 1) & 0x3FF
    return (imm_20 << 31) | (imm_10_1 << 21) | (imm_11 << 20) | \
           (imm_19_12 << 12) | (rd << 7) | opcode

def parse_mem_operand(operand):
    """Parse memory operand like '4(x1)' -> (offset, base_reg)"""
    match = re.match(r'(-?\d+|0x[0-9a-fA-F]+)\s*\(\s*(\w+)\s*\)', operand)
    if match:
        offset = int(match.group(1), 0)
        base = reg(match.group(2))
        return offset, base
    raise ValueError(f"Invalid memory operand: {operand}")

def assemble_instruction(line, labels=None, current_addr=0):
    """Assemble a single instruction"""
    # Remove comments and whitespace
    line = line.split('#')[0].split('//')[0].strip()
    if not line or line.endswith(':'):
        return None
    
    # Parse instruction and operands
    parts = re.split(r'[,\s]+', line, maxsplit=1)
    mnemonic = parts[0].lower()
    operands = parts[1] if len(parts) > 1 else ""
    ops = [o.strip() for o in operands.split(',') if o.strip()]
    
    # === RV32I Base Instructions ===
    
    # R-type arithmetic
    if mnemonic == 'add':
        return encode_r_type(0b0110011, reg(ops[0]), 0b000, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'sub':
        return encode_r_type(0b0110011, reg(ops[0]), 0b000, reg(ops[1]), reg(ops[2]), 0b0100000)
    elif mnemonic == 'and':
        return encode_r_type(0b0110011, reg(ops[0]), 0b111, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'or':
        return encode_r_type(0b0110011, reg(ops[0]), 0b110, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'xor':
        return encode_r_type(0b0110011, reg(ops[0]), 0b100, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'sll':
        return encode_r_type(0b0110011, reg(ops[0]), 0b001, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'srl':
        return encode_r_type(0b0110011, reg(ops[0]), 0b101, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'sra':
        return encode_r_type(0b0110011, reg(ops[0]), 0b101, reg(ops[1]), reg(ops[2]), 0b0100000)
    elif mnemonic == 'slt':
        return encode_r_type(0b0110011, reg(ops[0]), 0b010, reg(ops[1]), reg(ops[2]), 0b0000000)
    elif mnemonic == 'sltu':
        return encode_r_type(0b0110011, reg(ops[0]), 0b011, reg(ops[1]), reg(ops[2]), 0b0000000)
    
    # I-type arithmetic
    elif mnemonic == 'addi':
        return encode_i_type(0b0010011, reg(ops[0]), 0b000, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'andi':
        return encode_i_type(0b0010011, reg(ops[0]), 0b111, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'ori':
        return encode_i_type(0b0010011, reg(ops[0]), 0b110, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'xori':
        return encode_i_type(0b0010011, reg(ops[0]), 0b100, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'slti':
        return encode_i_type(0b0010011, reg(ops[0]), 0b010, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'sltiu':
        return encode_i_type(0b0010011, reg(ops[0]), 0b011, reg(ops[1]), imm(ops[2], 12))
    elif mnemonic == 'slli':
        shamt = imm(ops[2], 5, signed=False)
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), shamt)
    elif mnemonic == 'srli':
        shamt = imm(ops[2], 5, signed=False)
        return encode_i_type(0b0010011, reg(ops[0]), 0b101, reg(ops[1]), shamt)
    elif mnemonic == 'srai':
        shamt = imm(ops[2], 5, signed=False) | (0b0100000 << 5)
        return encode_i_type(0b0010011, reg(ops[0]), 0b101, reg(ops[1]), shamt)
    
    # Loads
    elif mnemonic == 'lw':
        offset, base = parse_mem_operand(ops[1])
        return encode_i_type(0b0000011, reg(ops[0]), 0b010, base, imm(offset, 12))
    elif mnemonic == 'lh':
        offset, base = parse_mem_operand(ops[1])
        return encode_i_type(0b0000011, reg(ops[0]), 0b001, base, imm(offset, 12))
    elif mnemonic == 'lb':
        offset, base = parse_mem_operand(ops[1])
        return encode_i_type(0b0000011, reg(ops[0]), 0b000, base, imm(offset, 12))
    elif mnemonic == 'lhu':
        offset, base = parse_mem_operand(ops[1])
        return encode_i_type(0b0000011, reg(ops[0]), 0b101, base, imm(offset, 12))
    elif mnemonic == 'lbu':
        offset, base = parse_mem_operand(ops[1])
        return encode_i_type(0b0000011, reg(ops[0]), 0b100, base, imm(offset, 12))
    
    # Stores
    elif mnemonic == 'sw':
        offset, base = parse_mem_operand(ops[1])
        return encode_s_type(0b0100011, 0b010, base, reg(ops[0]), imm(offset, 12))
    elif mnemonic == 'sh':
        offset, base = parse_mem_operand(ops[1])
        return encode_s_type(0b0100011, 0b001, base, reg(ops[0]), imm(offset, 12))
    elif mnemonic == 'sb':
        offset, base = parse_mem_operand(ops[1])
        return encode_s_type(0b0100011, 0b000, base, reg(ops[0]), imm(offset, 12))
    
    # Branches
    elif mnemonic == 'beq':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b000, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'bne':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b001, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'blt':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b100, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'bge':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b101, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'bltu':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b110, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'bgeu':
        offset = imm(ops[2], 13)
        return encode_b_type(0b1100011, 0b111, reg(ops[0]), reg(ops[1]), offset)
    elif mnemonic == 'beqz':  # Pseudo: beq rs, x0, offset
        offset = imm(ops[1], 13)
        return encode_b_type(0b1100011, 0b000, reg(ops[0]), 0, offset)
    elif mnemonic == 'bnez':  # Pseudo: bne rs, x0, offset
        offset = imm(ops[1], 13)
        return encode_b_type(0b1100011, 0b001, reg(ops[0]), 0, offset)
    
    # Jumps
    elif mnemonic == 'jal':
        if len(ops) == 1:  # jal offset (rd = ra)
            offset = imm(ops[0], 21)
            return encode_j_type(0b1101111, 1, offset)
        else:  # jal rd, offset
            offset = imm(ops[1], 21)
            return encode_j_type(0b1101111, reg(ops[0]), offset)
    elif mnemonic == 'jalr':
        if len(ops) == 1:  # jalr rs (rd = ra, offset = 0)
            return encode_i_type(0b1100111, 1, 0b000, reg(ops[0]), 0)
        elif len(ops) == 2:  # jalr rd, rs
            return encode_i_type(0b1100111, reg(ops[0]), 0b000, reg(ops[1]), 0)
        else:  # jalr rd, offset(rs)
            offset, base = parse_mem_operand(ops[1])
            return encode_i_type(0b1100111, reg(ops[0]), 0b000, base, imm(offset, 12))
    elif mnemonic == 'j':  # Pseudo: jal x0, offset
        offset = imm(ops[0], 21)
        return encode_j_type(0b1101111, 0, offset)
    elif mnemonic == 'jr':  # Pseudo: jalr x0, rs, 0
        return encode_i_type(0b1100111, 0, 0b000, reg(ops[0]), 0)
    elif mnemonic == 'ret':  # Pseudo: jalr x0, ra, 0
        return encode_i_type(0b1100111, 0, 0b000, 1, 0)
    
    # U-type
    elif mnemonic == 'lui':
        return encode_u_type(0b0110111, reg(ops[0]), imm(ops[1], 20, signed=False))
    elif mnemonic == 'auipc':
        return encode_u_type(0b0010111, reg(ops[0]), imm(ops[1], 20, signed=False))
    
    # Pseudo instructions
    elif mnemonic == 'nop':
        return encode_i_type(0b0010011, 0, 0b000, 0, 0)  # addi x0, x0, 0
    elif mnemonic == 'li':  # Load immediate (simplified: only supports 12-bit imm)
        val = imm(ops[1], 12)
        return encode_i_type(0b0010011, reg(ops[0]), 0b000, 0, val)
    elif mnemonic == 'mv':  # Move: addi rd, rs, 0
        return encode_i_type(0b0010011, reg(ops[0]), 0b000, reg(ops[1]), 0)
    elif mnemonic == 'not':  # xori rd, rs, -1
        return encode_i_type(0b0010011, reg(ops[0]), 0b100, reg(ops[1]), -1)
    elif mnemonic == 'neg':  # sub rd, x0, rs
        return encode_r_type(0b0110011, reg(ops[0]), 0b000, 0, reg(ops[1]), 0b0100000)
    elif mnemonic == 'seqz':  # sltiu rd, rs, 1
        return encode_i_type(0b0010011, reg(ops[0]), 0b011, reg(ops[1]), 1)
    elif mnemonic == 'snez':  # sltu rd, x0, rs
        return encode_r_type(0b0110011, reg(ops[0]), 0b011, 0, reg(ops[1]), 0b0000000)
    
    # === Zbb Extension Instructions ===
    
    # Zbb R-type
    elif mnemonic == 'andn':
        return encode_r_type(0b0110011, reg(ops[0]), 0b111, reg(ops[1]), reg(ops[2]), 0b0100000)
    elif mnemonic == 'orn':
        return encode_r_type(0b0110011, reg(ops[0]), 0b110, reg(ops[1]), reg(ops[2]), 0b0100000)
    elif mnemonic == 'xnor':
        return encode_r_type(0b0110011, reg(ops[0]), 0b100, reg(ops[1]), reg(ops[2]), 0b0100000)
    elif mnemonic == 'min':
        return encode_r_type(0b0110011, reg(ops[0]), 0b100, reg(ops[1]), reg(ops[2]), 0b0000101)
    elif mnemonic == 'max':
        return encode_r_type(0b0110011, reg(ops[0]), 0b110, reg(ops[1]), reg(ops[2]), 0b0000101)
    elif mnemonic == 'minu':
        return encode_r_type(0b0110011, reg(ops[0]), 0b101, reg(ops[1]), reg(ops[2]), 0b0000101)
    elif mnemonic == 'maxu':
        return encode_r_type(0b0110011, reg(ops[0]), 0b111, reg(ops[1]), reg(ops[2]), 0b0000101)
    elif mnemonic == 'rol':
        return encode_r_type(0b0110011, reg(ops[0]), 0b001, reg(ops[1]), reg(ops[2]), 0b0110000)
    elif mnemonic == 'ror':
        return encode_r_type(0b0110011, reg(ops[0]), 0b101, reg(ops[1]), reg(ops[2]), 0b0110000)
    
    # Zbb I-type (unary operations encoded as I-type with special immediates)
    elif mnemonic == 'clz':
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), 0b011000000000)
    elif mnemonic == 'ctz':
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), 0b011000000001)
    elif mnemonic == 'cpop':
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), 0b011000000010)
    elif mnemonic == 'sext.b':
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), 0b011000000100)
    elif mnemonic == 'sext.h':
        return encode_i_type(0b0010011, reg(ops[0]), 0b001, reg(ops[1]), 0b011000000101)
    elif mnemonic == 'zext.h':
        # For RV32: encoded as pack rd, rs, x0 (but simplified as I-type here)
        return encode_r_type(0b0110011, reg(ops[0]), 0b100, reg(ops[1]), 0, 0b0000100)
    elif mnemonic == 'orc.b':
        return encode_i_type(0b0010011, reg(ops[0]), 0b101, reg(ops[1]), 0b001010000111)
    elif mnemonic == 'rev8':
        return encode_i_type(0b0010011, reg(ops[0]), 0b101, reg(ops[1]), 0b011010011000)
    elif mnemonic == 'rori':
        shamt = imm(ops[2], 5, signed=False)
        return encode_i_type(0b0010011, reg(ops[0]), 0b101, reg(ops[1]), (0b0110000 << 5) | shamt)
    
    else:
        raise ValueError(f"Unknown instruction: {mnemonic}")

def assemble_file(filename):
    """Assemble a file and return list of (address, instruction, original_line)"""
    with open(filename, 'r') as f:
        lines = f.readlines()
    
    instructions = []
    addr = 0
    
    for line_num, line in enumerate(lines, 1):
        original = line.rstrip()
        line = line.split('#')[0].split('//')[0].strip()
        
        if not line:
            continue
        if line.endswith(':'):
            continue  # Skip labels for now
        
        try:
            encoded = assemble_instruction(line)
            if encoded is not None:
                instructions.append((addr, encoded, original))
                addr += 4
        except Exception as e:
            print(f"Error at line {line_num}: {e}", file=sys.stderr)
            print(f"  Line: {original}", file=sys.stderr)
    
    return instructions

def output_verilog(instructions, start_idx=0):
    """Output Verilog instruction_mem assignments"""
    for i, (addr, encoded, original) in enumerate(instructions):
        # Clean up original line for comment
        comment = original.strip().replace('//', '#').split('#')[0].strip()
        print(f"    instruction_mem[{start_idx + i}] = 32'h{encoded:08X};  // {comment}")

def output_hex(instructions):
    """Output hex file format"""
    for addr, encoded, _ in instructions:
        print(f"@{addr:08X} {encoded:08X}")

def interactive_mode(line):
    """Assemble a single instruction interactively"""
    try:
        encoded = assemble_instruction(line)
        if encoded is not None:
            print(f"Instruction: {line}")
            print(f"  Hex:    0x{encoded:08X}")
            print(f"  Binary: {encoded:032b}")
            print(f"  Verilog: 32'h{encoded:08X}")
    except Exception as e:
        print(f"Error: {e}")

def main():
    parser = argparse.ArgumentParser(description='RV32I + Zbb Assembler')
    parser.add_argument('input', nargs='?', help='Input assembly file')
    parser.add_argument('-i', '--interactive', help='Assemble single instruction')
    parser.add_argument('-f', '--format', choices=['verilog', 'hex'], default='verilog',
                        help='Output format (default: verilog)')
    parser.add_argument('-s', '--start', type=int, default=0,
                        help='Starting instruction index (default: 0)')
    
    args = parser.parse_args()
    
    if args.interactive:
        interactive_mode(args.interactive)
    elif args.input:
        instructions = assemble_file(args.input)
        if args.format == 'verilog':
            output_verilog(instructions, args.start)
        else:
            output_hex(instructions)
    else:
        # Demo mode
        print("// Demo: ChaCha20 Quarter Round")
        demo = [
            "add x1, x1, x2    // a += b",
            "xor x4, x4, x1    // d ^= a",
            "rol x4, x4, x5    // d = ROL(d, 16)",
            "add x3, x3, x4    // c += d",
            "xor x2, x2, x3    // b ^= c",
            "rol x2, x2, x5    // b = ROL(b, 12)",
            "cpop x6, x1       // popcount(a)",
        ]
        for line in demo:
            try:
                encoded = assemble_instruction(line)
                comment = line.split('//')[0].strip()
                print(f"    instruction_mem[?] = 32'h{encoded:08X};  // {comment}")
            except Exception as e:
                print(f"// Error: {e} -- {line}")

if __name__ == '__main__':
    main()


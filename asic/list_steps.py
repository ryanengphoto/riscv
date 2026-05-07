import openlane
from openlane.flows.classic import Classic
for step in Classic.Steps:
    print(step.id)

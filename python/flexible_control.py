# -*- coding: utf-8 -*-
"""flexible_control.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1pdVgC1dzVKbmQGQfCm4PRGAH2na_XqZy
"""

import shutil
import sys
import os.path
import numpy as np
import pandas as pd

if not shutil.which("pyomo"):
    !pip install -q pyomo
    assert(shutil.which("pyomo"))

if not (shutil.which("cbc") or os.path.isfile("cbc")):
    if "google.colab" in sys.modules:
        !apt-get install -y -qq coinor-cbc
    else:
        try:
            !conda install -c conda-forge coincbc 
        except:
            pass

assert(shutil.which("cbc") or os.path.isfile("cbc"))
    
from pyomo.environ import *

!git clone https://github.com/JacksonXi/optimisation

cd /content/optimisation/flexible/

"""**non-controlable energy < generated energy < (non-controlable energy + flexible energy)**"""

Flexibleindex = pd.read_csv("flexibleIndex.csv")
Consumer = list(Flexibleindex['Unnamed: 0'])
Consumer1 = list(Flexibleindex['Unnamed: 0'])
Consumer

flexibleindex = pd.read_csv("flexibleIndex.csv", index_col=0)
flexibleindex

power = pd.read_csv('power.csv', index_col=0)
power

appliances = list(flexibleindex.keys())
appliances

bid = pd.read_csv('bid.csv', index_col=0)
bid

n = len(bid)
consumer = [] 
while n != 0:
    max = Consumer[0]
    for i in range(0,n):
      if bid['bid'][max] < bid['bid'][Consumer[i]]:
          max = Consumer[i]
      else:
          max = max
    consumer.append(max)      
    Consumer.remove(max)
    n -= 1
print(Consumer)
print(consumer)

generatedEnergy = pd.read_csv('generated energy.csv')
Prosumer = list(generatedEnergy['Unnamed: 0'])
Prosumer1 = list(generatedEnergy['Unnamed: 0'])
Prosumer

generated_energy = pd.read_csv('generated energy.csv', index_col=0)
generated_energy

n = len(generated_energy)
prosumer = [] 
while n != 0:
    max = Prosumer[0]
    for i in range(0,n):
      if generated_energy['generated energy'][max] < generated_energy['generated energy'][Prosumer[i]]:
          max = Prosumer[i]
      else:
          max = max
    prosumer.append(max)      
    Prosumer.remove(max)
    n -= 1
print(prosumer)
print(Prosumer)

"""**Calaulate the total generated energy**"""

TotalEnergy = 0

for p in prosumer:
    TotalEnergy += generated_energy['generated energy'][p]

TotalEnergy

"""**Calculate the total energy of non-controlable loads and revenue** 




"""

demand = pd.read_csv('demand.csv', index_col=0)
print(demand)

d = 0
for c in consumer:
    d += demand['demand'][c]*bid['bid'][c]
print(d)

D = 0
for c in consumer:
    D += demand['demand'][c]
print(D)

model = ConcreteModel()
model.dual = Suffix(direction=Suffix.IMPORT)

model.switches = Var(appliances, consumer, domain = Binary)

model.revenue = Objective(expr = d + sum(flexibleindex[a][c]*power[a][c]*bid['bid'][c]*model.switches[a, c] for c in consumer for a in appliances),
                          sense = maximize)

model.supply = Constraint(expr = (D + sum(flexibleindex[a][c]*power[a][c]*model.switches[a, c] for c in consumer for a in appliances)) <= TotalEnergy)


results = SolverFactory('cbc').solve(model)
results.write()

for c in Consumer1:
    for a in appliances:
        if model.switches[a,c]() == 1:
          print("{:<5s} {:<2s} {:<12} {:<15} {:<8}".format('User', c , ': The state of', a,'is ON'))
        elif model.switches[a,c]() == 0:
          print("{:<5s} {:<2s} {:<12} {:<15} {:<8}".format('User', c , ': The state of', a,'is OFF'))
        else:
          print("{:<5s} {:<2s} {:<12} {:<15} {:<8}".format('User', c , ': The state of', a,'is UNCONTROLABLE'))
    print('\n')

"""**Calculating the optimized energy demand**"""

for c in consumer:
    for a in appliances:
        if model.switches[a, c]() != None:
            demand['demand'][c] += power[a][c]*model.switches[a, c]()

demand

Model = ConcreteModel()
Model.dual = Suffix(direction=Suffix.IMPORT)

Model.transport = Var(prosumer, consumer , domain = NonNegativeReals)

Model.revenue = Objective(expr = sum(Model.transport[p, c]*bid['bid'][c] for p in prosumer for c in consumer), 
                           sense = maximize)

Model.supply = ConstraintList()
for p in prosumer:
      Model.supply.add(sum(Model.transport[p, c] for c in consumer) <= generated_energy['generated energy'][p])

Model.demand = ConstraintList()
for c in consumer:
      Model.demand.add(sum(Model.transport[p, c] for p in prosumer) == demand['demand'][c])

results = SolverFactory('cbc').solve(Model)
results.write()

for p in prosumer:
    for c in consumer:
        print(p, c, Model.transport[p,c]())

if 'ok' == str(results.Solver.status):
    print("Total Community Revenue = ",model.revenue())
    print("\nTransport Table:")
    for p in Prosumer1:
        for c in Consumer1:
            if Model.transport[p,c]() > 0:
                print("Transport from ", p," to ", c, ":", Model.transport[p,c](),'KWh')
else:
    print("No Valid Solution Found")

n = 0
if 'ok' == str(results.Solver.status):
    print("Personal Revenue:\n")
    for p in prosumer:
        for c in consumer:
            if Model.transport[p,c]() > 0:
                print("Balance from ", c," to ", p, ":", Model.transport[p,c]() * bid['bid'][c])
else:
    print("No Valid Solution Found")

n = 0
if 'ok' == str(results.Solver.status):
    print("Personal Revenue:\n")
    for p in prosumer:
      for c in consumer:
          n += Model.transport[p, c]() * bid['bid'][c] 
      print("The revenue of",p ,":" , n)
      n = 0
else:
    print("No Valid Solution Found")

n = 0
if 'ok' == str(results.Solver.status):
    print("The exported electricity to the grid:\n")
    for p in prosumer:
        n = generated_energy['generated energy'][p]
        for c in consumer:
            n -= Model.transport[p, c]()
        if n > 0 :
            print(p, "will export ",n , "KWh to the grid")

n = 0
if 'ok' == str(results.Solver.status):
    print("Personal Revenue:\n")
    for c in Consumer1:
      for p in Prosumer1:
          n += Model.transport[p, c]()
      print("The received energy of",c ,":" , n)
      n = 0
else:
    print("No Valid Solution Found")
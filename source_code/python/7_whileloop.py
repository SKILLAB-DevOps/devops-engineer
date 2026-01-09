#!/usr/bin/env python3.11
"""While loop in Python.""" ""
current_number = 1
while current_number <= 5:
    print(current_number)
    current_number += 1

user_input = "\nEnter the name of a country you will visit:"
user_input += "\n(Write 'exit' when you are done.) "

while True:
    country = input(user_input)

    if country == "exit":
        break
    elif country == "romania":
        continue
    else:
        print(f"I'm going to {country.title()}!")

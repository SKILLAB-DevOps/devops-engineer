#!/usr/bin/env python3.11
"""Classes in Python."""


class Student:
    """
    A class used to represent a student.

    ...

    Attributes
    ----------
    name: str
        the name of the students
    age: int
        the age of the students

    Methods
    -------
    learn()
        Simulate a student learn.
    take_exam()
        Simulate taking over good results.
    """

    def __init__(self, name, age):
        """Initialize name and age attributes.

        Attributes
        ----------
        name: str
            the name of the students
        age: int
            the age of the students

        Returns:
            None
        """
        self.name = name
        self.age = age

    def learn(self):
        """Simulate a student learn.

        Prints status

        Attributes
        ----------
        name: str
            the name of the students
        age: int
            the age of the students

        Returns:
            None
        """
        print(f"{self.name} is now learning.")

    def take_exam(self):
        """Simulate taking over good results.

        Prints encouragement

        Attributes
        ----------
        name: str
            the name of the students
        age: int
            the age of the students

        Returns:
            None
        """
        print(f"{self.name} did great!")


student1 = Student("John Wick", 47)
student2 = Student("Macaulay Culkin", 12)

print(f"Student1 is {student1.name} and is {student1.age}")
print(f"Student2 is {student2.name} and is {student2.age}")

student1.learn()
student1.take_exam()

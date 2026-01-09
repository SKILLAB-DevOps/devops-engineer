###########
4.6 Classes
###########

Object-oriented programming (OOP) is a programming paradigm based on the concept of "objects", which can contain data and code. The data is in the form of fields (often known as attributes or properties), and the code is in the form of procedures (often known as methods).

Generating an object from a class is called instantiation.
You work with instances of a class, which are created by the process of instantiating an object from a class. 

===============
Using functions
===============

.. code-block:: python
    
    class Student:
        """
        A class is used to represent a student.

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
            Simulate a student's learning.
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
            """Simulate a student's learning.

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

    print(f"Student1 is {student1.name} and is {student1.age}")
    print(f"Student2 is {student2.name} and is {student2.age}")

    student1 = Student("John Wick", 47)
    student2 = Student("Macaulay Culkin", 12)

A method is a function that is a part of a class.
Everything you learned about functions also applies to methods; the only difference in practice is that we'll refer to methods as methods.

``__init__`` is a special method called a constructor that Python calls when you create a new instance of this class. 

Other special methods include ``__str__``, ``__eq__``, and ``__len__``. You can override these methods to customize how they work with your objects.

================
Buzzwords of OOP
================

- **Class**: A blueprint for how something should be defined. It doesn't actually contain any data.
- **Object**: An instance of a class. It contains the actual data.
- **Attribute**: A bit of data inside a class or object.
- **Method**: An action that a class or object can take.
- **Inheritance**: The ability to extend a class to make a new class.
- **Composition**: The ability to call functions from another class, or build a bigger class from smaller classes.
- **Encapsulation**: A way to make sure that data can only be modified in certain ways.
- **Polymorphism**: A way to make different classes interchangeable with each other.
- **Class variable**: A variable that's the same for every instance of a class.
- **Instance variable**: A variable that's unique to each instance of a class.
- **Constructor**: The method that runs when an object is instantiated from a class.

++++++++++++++++++++
What is Inheritance?
++++++++++++++++++++

Inheritance is the process by which one class takes on the attributes and methods of another. Newly formed classes are called child classes, and the classes that child classes are derived from are called parent classes.

.. code-block:: python

    # Example on inheritance in Python
    # Parent class
    class Animal:
        def __init__(self, name, weight):
            self.name = name
            self.weight = weight

        def eat(self):
            print(f"{self.name} is eating.")

        def drink(self):
            print(f"{self.name} is drinking.")

    # Child class
    class Frog(Animal):
        def jump(self):
            print(f"{self.name} is jumping.")

    # Child class
    class Dog(Animal):
        def bark(self):
            print(f"{self.name} is barking.")

    frog = Frog("Kermit", 0.5)
    dog = Dog("Scooby", 10)

    frog.eat()
    frog.drink()
    frog.jump()

    dog.eat()
    dog.drink()
    dog.bark()

++++++++++++++++++++
What is Composition?
++++++++++++++++++++

Composition is a way of building up larger classes from smaller ones. It refers to the way a class is made up of other classes as opposed to inheritance, which refers to the way a class is derived from another class.

.. code-block:: python

    # Example on composition in Python
    class Book:
        def __init__(self, title, price, author=None):
            self.title = title
            self.price = price

            self.author = author

            self.chapters = []

        def add_chapter(self, chapter):
            self.chapters.append(chapter)

        def get_book_page_count(self):
            result = 0
            for ch in self.chapters:
                result += ch.page_count
            return result
    
    class Author:
        def __init__(self, fname, lname):
            self.fname = fname
            self.lname = lname

        def __str__(self):
            return f"{self.fname} {self.lname}"

    class Chapter:
        def __init__(self, name, page_count):
            self.name = name
            self.page_count = page_count

    author = Author("Leo", "Tolstoy")
    b1 = Book("War and Peace", 39.0, author)

++++++++++++++++++++++
What is Encapsulation?
++++++++++++++++++++++

Encapsulation is the process of restricting access to methods and variables in a class in order to prevent direct data modification so it prevents accidental modification of data.

.. code-block:: python

    # Example on encapsulation in Python
    class Person:

    def __init__(self, name, age):
        self._name = name 
        self._age = age

    def get_name(self):
        return self._name

    def set_name(self, name):
        self._name = name

    def get_age(self):
        return self._age

    def set_age(self, age):
        if age < 0:
            raise ValueError("Age cannot be negative")
        self._age = age

    p = Person("John", 25)
    print(p.get_name()) # Prints "John"

    p.set_name("Jane") 
    print(p.get_name()) # Prints "Jane"
    print(p.get_age()) # Prints 25

    p.set_age(27)
    print(p.get_age()) # Prints 27

    p.set_age(-27) # Raises ValueError

 
+++++++++++++++++++++
What is Polymorphism?
+++++++++++++++++++++

Polymorphism in Python refers to the ability to use the same syntax for different types of objects. There are two main ways polymorphism is achieved in Python:

1. Inheritance and overriding - A parent class can be inherited by multiple child classes, each of which can override the parent class methods. 

.. code-block:: python

    # Example on polymorphism in Python
    class Shape:
    def area(self):
        pass

    class Square(Shape):
    def area(self):
        # calculate area for square
        pass

    class Circle(Shape):
    def area(self):
        # calculate area for circle
        pass
    # Here Square and Circle inherit from Shape, but override the area method to provide their own implementation.

2. Duck typing - Different unrelated objects can have the same method names, allowing them to be used interchangeably.

.. code-block:: python

    class Car:
    def drive(self):
        print("Driving the car")

    class Bike:
    def drive(self):
        print("Driving the bike")

    # `vehicle` can refer to either a Car or Bike object 
    vehicle.drive()
    # As long as objects have a drive method, they can be treated the same way despite having different underlying types.

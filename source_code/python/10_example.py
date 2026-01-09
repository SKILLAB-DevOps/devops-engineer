import random
import nltk
import argparse
from nltk.corpus import words

"""A python script that uses classes and functions to create a simple username generator"""


class UsernameGenerator:
    """A class to generate random usernames from English words.

    Attributes:
        num_words (int): The number of words per username.
        num_users (int): The number of usernames to generate.
        word_list (list): The list of English words to use for generating usernames.
    """

    def __init__(self, num_words=2, num_users=1):
        """
        The constructor for UsernameGenerator class.

        Parameters:
            num_words (int): The number of words per username. Defaults to 2.
            num_users (int): The number of usernames to generate. Defaults to 1.
        """
        self.num_words = num_words
        self.num_users = num_users

        # Download the words corpus if it hasn't been downloaded yet
        try:
            nltk.data.find("corpora/words")
        except LookupError:
            nltk.download("words")

        # Load the list of English words
        self.word_list = words.words()

    def generate_username(self):
        """
        Generates a single username.

        Returns:
            str: A random username composed of English words.
        """
        username = "".join(
            random.choice(self.word_list).capitalize() for _ in range(self.num_words)
        )
        return username

    def generate_usernames(self):
        """
        Generates a list of usernames.

        Returns:
            list: A list of random usernames, each composed of English words.
        """
        return [self.generate_username() for _ in range(self.num_users)]


if __name__ == "__main__":
    # Create argument parser
    parser = argparse.ArgumentParser(
        description="Generate random usernames from English words."
    )
    parser.add_argument(
        "-w", "--words", type=int, help="number of words per username", default=2
    )
    parser.add_argument(
        "-u", "--users", type=int, help="number of usernames to generate", default=1
    )
    args = parser.parse_args()

    # Create a username generator
    generator = UsernameGenerator(num_words=args.words, num_users=args.users)

    # Generate usernames
    usernames = generator.generate_usernames()
    for username in usernames:
        print(username)

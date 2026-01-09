# Import the required libraries
import requests
from bs4 import BeautifulSoup


def main():
    # Step 1: Fetch Wikipedia page
    url = "https://en.wikipedia.org/wiki/Python_(genus)"
    response = requests.get(url)

    # Check if the page was fetched successfully
    if response.status_code != 200:
        print("Failed to get the Wikipedia page.")
        return

    # Step 2: Initialize BeautifulSoup object
    # We feed the HTML content of the page to the BeautifulSoup constructor
    soup = BeautifulSoup(response.text, "html.parser")

    # Step 2.1: Find the 'Species' section
    # The 'Species' section has a 'span' tag with the 'id' attribute set to 'Species'
    species_section = soup.find("span", {"id": "Species"})

    # Find the nearest parent header of the 'Species' section
    species_section_header = species_section.find_parent()

    # Step 2.2: Find the next unordered list (ul)
    # After finding the 'Species' header, we look for the next 'ul' tag (unordered list)
    species_ul = species_section_header.find_next_sibling("ul")

    # Step 2.3: Initialize an empty list to store species names
    species_list = []

    # Step 2.4: Loop through the list items in the unordered list
    # Each species name is within a 'li' tag (list item)
    for list_item in species_ul.find_all("li"):
        species_name = list_item.text.strip()  # Remove leading/trailing whitespace
        species_list.append(species_name)  # Add to our list of species names

    # Step 3: Write to a new file
    with open("python_species.txt", "w") as f:
        for species in species_list:
            f.write(f"{species}\n")

        # Step 4: Append the count of species at the end
        f.write(f"\nTotal number of species: {len(species_list)}")

    print("Species names and count have been saved to python_species.txt.")


if __name__ == "__main__":
    main()

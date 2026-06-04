"""
Simple string utility functions for text manipulation.
"""

def reverse_string(text):
    """Reverse a string."""
    return text[::-1]


def is_palindrome(text):
    """Check if a string is a palindrome (reads the same forwards and backwards)."""
    # Remove spaces and convert to lowercase for comparison
    cleaned = text.replace(" ", "").lower()
    return cleaned == cleaned[::-1]


def count_vowels(text):
    """Count the number of vowels in a string."""
    vowels = "aeiouAEIOU"
    count = 0
    for char in text:
        if char in vowels:
            count += 1
    return count


def capitalize_words(text):
    """Capitalize the first letter of each word in a string."""
    return text.title()


def count_words(text):
    """Count the number of words in a string."""
    if not text or text.isspace():
        return 0
    return len(text.split())


if __name__ == "__main__":
    # Demo usage
    print("String Utils Demo")
    print("-" * 40)
    
    text = "hello world"
    print(f"Original: {text}")
    print(f"Reversed: {reverse_string(text)}")
    print(f"Capitalized: {capitalize_words(text)}")
    print(f"Word count: {count_words(text)}")
    print(f"Vowel count: {count_vowels(text)}")
    
    palindrome = "racecar"
    print(f"\nIs '{palindrome}' a palindrome? {is_palindrome(palindrome)}")

"""
Unit tests for string utility functions.
"""

import unittest
from string_utils import (
    reverse_string,
    is_palindrome,
    count_vowels,
    capitalize_words,
    count_words
)


class TestStringUtils(unittest.TestCase):
    """Test cases for string utility functions."""
    
    def test_reverse_string(self):
        """Test string reversal."""
        self.assertEqual(reverse_string("hello"), "olleh")
        self.assertEqual(reverse_string("Python"), "nohtyP")
        self.assertEqual(reverse_string(""), "")
        self.assertEqual(reverse_string("a"), "a")
    
    def test_is_palindrome(self):
        """Test palindrome detection."""
        self.assertTrue(is_palindrome("racecar"))
        self.assertTrue(is_palindrome("A man a plan a canal Panama"))
        self.assertTrue(is_palindrome(""))
        self.assertFalse(is_palindrome("hello"))
        self.assertFalse(is_palindrome("Python"))
    
    def test_count_vowels(self):
        """Test vowel counting."""
        self.assertEqual(count_vowels("hello"), 2)
        self.assertEqual(count_vowels("AEIOU"), 5)
        self.assertEqual(count_vowels("xyz"), 0)
        self.assertEqual(count_vowels(""), 0)
        self.assertEqual(count_vowels("Programming"), 3)
    
    def test_capitalize_words(self):
        """Test word capitalization."""
        self.assertEqual(capitalize_words("hello world"), "Hello World")
        self.assertEqual(capitalize_words("python programming"), "Python Programming")
        self.assertEqual(capitalize_words(""), "")
        self.assertEqual(capitalize_words("a"), "A")
    
    def test_count_words(self):
        """Test word counting."""
        self.assertEqual(count_words("hello world"), 2)
        self.assertEqual(count_words("one"), 1)
        self.assertEqual(count_words(""), 0)
        self.assertEqual(count_words("   "), 0)
        self.assertEqual(count_words("Python is awesome"), 3)


if __name__ == "__main__":
    unittest.main()

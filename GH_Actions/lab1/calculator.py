"""
A simple calculator module for basic arithmetic operations.
"""

class Calculator:
    """A calculator class that performs basic arithmetic operations."""
    
    def add(self, a, b):
        """Add two numbers and return the result."""
        return a + b
    
    def subtract(self, a, b):
        """Subtract b from a and return the result."""
        return a - b
    
    def multiply(self, a, b):
        """Multiply two numbers and return the result."""
        return a * b
    
    def divide(self, a, b):
        """Divide a by b and return the result."""
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
    
    def power(self, base, exponent):
        """Raise base to the power of exponent."""
        return base ** exponent
    
    def square_root(self, number):
        """Calculate the square root of a number."""
        if number < 0:
            raise ValueError("Cannot calculate square root of negative number")
        return number ** 0.5


def main():
    """Demo function to show calculator usage."""
    import sys

    calc = Calculator()

    if len(sys.argv) == 3:
        operation = sys.argv[1]
        try:
            a = float(sys.argv[2])
        except ValueError:
            print(f"Error: '{sys.argv[2]}' is not a valid number.")
            sys.exit(1)

        operations_single = {
            "sqrt": calc.square_root,
        }
        if operation in operations_single:
            try:
                result = operations_single[operation](a)
                print(f"{operation}({a}) = {result}")
            except ValueError as e:
                print(f"Error: {e}")
                sys.exit(1)
        else:
            print(f"Error: '{operation}' requires two numbers.")
            print("Usage: python calculator.py <operation> <a> <b>")
            sys.exit(1)

    elif len(sys.argv) == 4:
        operation = sys.argv[1]
        try:
            a = float(sys.argv[2])
            b = float(sys.argv[3])
        except ValueError:
            print(f"Error: '{sys.argv[2]}' or '{sys.argv[3]}' is not a valid number.")
            sys.exit(1)

        operations = {
            "add":      calc.add,
            "subtract": calc.subtract,
            "multiply": calc.multiply,
            "divide":   calc.divide,
            "power":    calc.power,
        }

        if operation not in operations:
            print(f"Error: unknown operation '{operation}'.")
            print(f"Available: {', '.join(list(operations.keys()) + ['sqrt'])}")
            sys.exit(1)

        try:
            result = operations[operation](a, b)
            print(f"{result}")
        except ValueError as e:
            print(f"Error: {e}")
            sys.exit(1)

    else:
        print("Calculator Demo")
        print("-" * 40)
        print(f"5 + 3 = {calc.add(5, 3)}")
        print(f"10 - 4 = {calc.subtract(10, 4)}")
        print(f"6 * 7 = {calc.multiply(6, 7)}")
        print(f"20 / 4 = {calc.divide(20, 4)}")
        print(f"2 ^ 8 = {calc.power(2, 8)}")
        print(f"√16 = {calc.square_root(16)}")
        print()
        print("Usage: python calculator.py <operation> <a> [b]")
        print("  Operations: add, subtract, multiply, divide, power, sqrt")
        print("  Example:    python calculator.py add 5 3")


if __name__ == "__main__":
    main()

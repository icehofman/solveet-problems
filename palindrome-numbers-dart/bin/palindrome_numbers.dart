
class Palindrome {

    int reverse(int n) => int.parse(n.toString().split('').reversed.join());

    boolean isPalindrome(int n) => n.toString() == reverse(n).toString();

    boolean isSumPalindrome(int n) => isPalindrome(n + reverse(n));

}

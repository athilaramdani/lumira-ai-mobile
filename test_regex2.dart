void main() {
  String text4 = '<unused94>thought\nMissing end tag. But here is the answer.';
  
  String res = text4.replaceAll(RegExp(r'<unused94>thought[\s\S]*?(?:</unused94>|<unused94>|$)'), '');
  print('---4---\n' + res.trim());
}

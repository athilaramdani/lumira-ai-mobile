void main() {
  String text1 = '<unused94>thought\nThis is a thought process.\n</unused94>\nThis is the actual answer.';
  String text2 = '<unused94>thought\nAnother thought process.\n<unused94>\nAnother answer.';
  String text3 = '<think>\nDeepseek thought process.\n</think>\nDeepseek answer.';
  String text4 = '<unused94>thought\nMissing end tag. But here is the answer.';
  
  String clean(String t) {
    String res = t.replaceAll(RegExp(r'<unused94>thought[\s\S]*?(?:</unused94>|<unused94>)'), '');
    res = res.replaceAll(RegExp(r'<think>[\s\S]*?</think>'), '');
    
    // Fallback if missing end tag (removes everything from <unused94>thought to the end if not already removed)
    // Actually, if we do that, we might lose the answer if the model just forgot the tag.
    // Let's just see how the regex performs.
    return res.trim();
  }
  
  print('---1---\n' + clean(text1));
  print('---2---\n' + clean(text2));
  print('---3---\n' + clean(text3));
  print('---4---\n' + clean(text4));
}

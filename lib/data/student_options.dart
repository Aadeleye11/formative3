/// Derives up to two initials from a full name, e.g. "Ayomide Adeleye" -> "AA".
String initialsFromName(String name, {String fallback = ''}) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();
  if (words.isEmpty) return fallback;
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return (words.first.substring(0, 1) + words.last.substring(0, 1))
      .toUpperCase();
}

/// Program options offered in the student setup wizard and Edit Profile.
const kPrograms = [
  ('Computer Science', 'BSc'),
  ('Entrepreneurship', 'BA'),
  ('Global Challenges', 'BA'),
  ('International Business & Trade', 'BA'),
];

/// Interest tags offered in the student setup wizard and Skills & Interests.
const kInterestOptions = [
  'Design',
  'Engineering',
  'Data',
  'Marketing',
  'Content',
  'Operations',
  'Business',
  'Finance',
  'No-Code',
  'Product',
  'Research',
  'UI/UX',
];

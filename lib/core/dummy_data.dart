class DummyData {
  static final List<Map<String, dynamic>> subjects = [
    {'id': 's1', 'name': 'History (इतिहास)'},
    {'id': 's2', 'name': 'Geography (भूगोल)'},
  ];

  static final List<Map<String, dynamic>> topics = [
    {'id': 't1', 'subjectId': 's1', 'name': 'Indus Valley Civilization'},
    {'id': 't2', 'subjectId': 's1', 'name': 'Vedic Period'},
    {'id': 't3', 'subjectId': 's2', 'name': 'Indian Rivers'},
  ];

  static final List<Map<String, dynamic>> sets = [
    {'id': 'set1', 'topicId': 't1', 'name': 'Set 1'},
    {'id': 'set2', 'topicId': 't1', 'name': 'Set 2 (Locked)'},
    {'id': 'set3', 'topicId': 't2', 'name': 'Set 1'},
  ];

  static final List<Map<String, dynamic>> mcqs = [
    {
      'setId': 'set1',
      'question': 'Which was a major port of the Indus Valley Civilization?',
      'options': ['Lothal', 'Ujjain', 'Pataliputra', 'Kashi'],
      'correctAnswer': 'Lothal',
    },
    {
      'setId': 'set1',
      'question': 'The Great Bath was found at which IVC site?',
      'options': ['Harappa', 'Mohenjo-Daro', 'Lothal', 'Dholavira'],
      'correctAnswer': 'Mohenjo-Daro',
    },
     {
      'setId': 'set1',
      'question': 'The staple food of the Vedic Aryans was:',
      'options': ['Barley and rice', 'Milk and its products', 'Rice and pulses', 'Vegetables and fruits'],
      'correctAnswer': 'Milk and its products',
    },
  ];
}

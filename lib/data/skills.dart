/// Shown before a student searches.
const kPopularSkills = [
  'Flutter',
  'Figma',
  'SQL',
  'Copywriting',
  'Video Editing',
  'Firebase',
  'Python',
  'Public Speaking',
  'Canva',
  'Data Analysis',
  'UI Design',
  'Notion',
  'Photography',
];

/// The full searchable pool.
const kAllSkills = [
  // Programming & computer science
  'Python', 'Java', 'JavaScript', 'TypeScript', 'C', 'C++', 'C#', 'Go',
  'Rust', 'Kotlin', 'Swift', 'Dart', 'PHP', 'Ruby', 'R', 'MATLAB', 'SQL',
  'NoSQL', 'HTML', 'CSS', 'Flutter', 'React', 'React Native', 'Vue.js',
  'Angular', 'Node.js', 'Django', 'Flask', 'Spring Boot', '.NET', 'GraphQL',
  'REST APIs', 'Firebase', 'AWS', 'Microsoft Azure', 'Google Cloud Platform',
  'Docker', 'Kubernetes', 'Git', 'CI/CD', 'Linux', 'Bash Scripting',
  'Machine Learning', 'Deep Learning', 'Computer Vision',
  'Natural Language Processing', 'Data Structures & Algorithms',
  'Cybersecurity', 'Blockchain', 'Solidity', 'Unity', 'Game Development',
  'Embedded Systems', 'IoT', 'Web Scraping', 'Automation Testing', 'DevOps',
  'Web3', 'Prompt Engineering', 'Large Language Models', 'API Integration',
  'Microservices Architecture', 'System Design', 'Database Administration',
  'Network Administration', 'Cloud Security', 'Penetration Testing',
  'Ethical Hacking', 'Augmented Reality', 'Virtual Reality', 'Game Design',
  'No-Code Development',

  // Design
  'UI Design', 'UX Design', 'UX Research', 'Figma', 'Adobe XD', 'Sketch',
  'Adobe Photoshop', 'Adobe Illustrator', 'Adobe InDesign', 'Canva',
  'Graphic Design', 'Motion Graphics', 'Video Editing', 'Animation',
  '3D Modeling', 'Blender', 'Wireframing', 'Prototyping', 'Design Systems',
  'Typography', 'Branding', 'Illustration', 'Product Design',
  'Interaction Design', 'Accessibility Design',

  // Data & analytics
  'Data Analysis', 'Data Visualization', 'Data Cleaning', 'Data Engineering',
  'Data Science', 'Statistics', 'Excel', 'Power BI', 'Tableau',
  'Google Analytics', 'A/B Testing', 'Predictive Modeling', 'Big Data',
  'Data Mining', 'Business Intelligence', 'SPSS', 'Stata', 'Pandas',
  'NumPy', 'TensorFlow', 'PyTorch', 'Scikit-learn', 'Forecasting',
  'Quantitative Research', 'Qualitative Research',

  // Marketing
  'Digital Marketing', 'Social Media Marketing', 'Content Marketing',
  'Email Marketing', 'SEO', 'SEM', 'Copywriting', 'Brand Strategy',
  'Influencer Marketing', 'Marketing Analytics', 'Growth Hacking',
  'Community Management', 'Public Relations', 'Campaign Management',
  'Market Research', 'Customer Segmentation', 'Affiliate Marketing',
  'Paid Advertising', 'Google Ads', 'Facebook Ads', 'TikTok Marketing',
  'Video Marketing', 'Podcasting', 'Event Marketing',
  'Marketing Automation', 'CRM Management', 'Lead Generation',
  'Conversion Rate Optimization', 'Storytelling', 'Media Buying',

  // Business & entrepreneurship
  'Business Development', 'Strategic Planning', 'Business Model Design',
  'Pitching', 'Fundraising', 'Venture Capital', 'Financial Modeling',
  'Startup Operations', 'Lean Startup Methodology', 'Market Validation',
  'Product Management', 'Product Strategy', 'Competitive Analysis',
  'Negotiation', 'Partnership Development', 'Franchise Development',
  'Supply Chain Management', 'Import/Export', 'International Trade',
  'Business Law', 'Contract Management', 'Risk Management',
  'Change Management', 'Innovation Management', 'Corporate Strategy',
  'Mergers & Acquisitions', 'Investment Analysis', 'Business Analytics',
  'Operations Management', 'Process Improvement', 'Vendor Management',
  'E-commerce Management', 'Retail Management', 'Cooperative Management',
  'Agribusiness',

  // Finance & accounting
  'Financial Accounting', 'Managerial Accounting', 'Bookkeeping',
  'Budgeting', 'Financial Analysis', 'Financial Planning', 'Taxation',
  'Auditing', 'Investment Banking', 'Corporate Finance', 'Personal Finance',
  'Microfinance', 'Payroll Management', 'QuickBooks', 'Xero',
  'Cost Accounting', 'Financial Reporting', 'Credit Analysis',
  'Actuarial Science', 'Cryptocurrency',

  // Writing & content
  'Content Writing', 'Technical Writing', 'Grant Writing', 'Editing',
  'Proofreading', 'Blogging', 'Scriptwriting', 'Journalism',
  'Creative Writing', 'Ghostwriting', 'Speechwriting', 'Translation',
  'Localization', 'Transcription', 'Research Writing', 'Report Writing',
  'Resume Writing', 'UX Writing', 'Academic Writing', 'SEO Writing',

  // Operations & admin
  'Project Management', 'Agile Methodology', 'Scrum', 'Kanban',
  'Time Management', 'Event Planning', 'Logistics Coordination',
  'Inventory Management', 'Office Administration', 'Scheduling',
  'Data Entry', 'Customer Support', 'Help Desk Support', 'Quality Assurance',
  'Procurement', 'Facilities Management', 'Records Management',
  'Onboarding', 'Training & Development', 'Recruitment',

  // Sales & customer service
  'Sales Strategy', 'Cold Calling', 'Account Management',
  'Customer Relationship Management', 'Customer Success', 'Upselling',
  'Sales Forecasting', 'Retail Sales', 'B2B Sales', 'B2C Sales',
  'Telemarketing', 'Client Retention', 'Customer Experience Design',
  'Complaint Resolution', 'Cross-selling',

  // Leadership & soft skills
  'Public Speaking', 'Leadership', 'Team Management', 'Conflict Resolution',
  'Critical Thinking', 'Problem Solving', 'Decision Making',
  'Emotional Intelligence', 'Adaptability', 'Collaboration', 'Mentoring',
  'Coaching', 'Networking', 'Presentation Skills', 'Active Listening',
  'Cultural Competence', 'Work Ethic', 'Creativity', 'Innovation',
  'Resilience', 'Stress Management', 'Delegation', 'Facilitation',
  'Diplomacy', 'Empathy', 'Self-motivation', 'Attention to Detail',
  'Multitasking', 'Feedback Delivery', 'Community Organizing',

  // Research & science
  'Research Methodology', 'Literature Review', 'Lab Techniques',
  'Field Research', 'Survey Design', 'Environmental Science', 'Biology',
  'Chemistry', 'Physics', 'Public Health', 'Epidemiology',
  'Nutrition Science', 'Climate Science', 'Renewable Energy',
  'Water Resource Management', 'Agricultural Science', 'Soil Science',
  'Genetics', 'Biotechnology', 'Robotics',

  // Engineering & hardware
  'Mechanical Engineering', 'Electrical Engineering', 'Civil Engineering',
  'CAD Design', 'AutoCAD', 'SolidWorks', 'Circuit Design', 'Arduino',
  'Raspberry Pi', '3D Printing', 'Renewable Energy Systems',
  'HVAC Systems', 'Structural Analysis', 'Manufacturing Processes',
  'Quality Control',

  // Education & social impact
  'Curriculum Design', 'Tutoring', 'Instructional Design',
  'Community Outreach', 'Volunteer Coordination', 'Grant Management',
  'Nonprofit Management', 'Fundraising for Nonprofits',
  'Program Evaluation', 'Advocacy', 'Policy Analysis',
  'Sustainability Consulting', 'Social Entrepreneurship',
  'Impact Measurement', 'Peer Mentoring',

  // Languages
  'English', 'French', 'Kinyarwanda', 'Swahili', 'Portuguese', 'Spanish',
  'Arabic', 'Mandarin Chinese', 'German', 'Amharic', 'Hausa', 'Yoruba',
  'Zulu', 'Wolof', 'Somali',

  // Media & creative
  'Photography', 'Videography', 'Podcast Production', 'Music Production',
  'Sound Design', 'Voice Acting', 'Film Editing', 'Cinematography',
  'Live Streaming', 'Broadcasting', 'Radio Production', 'Set Design',
  'Costume Design', 'Fashion Design', 'Interior Design',

  // Agriculture & agritech
  'Precision Agriculture', 'Crop Management', 'Livestock Management',
  'Irrigation Systems', 'Agricultural Extension', 'Post-harvest Handling',
  'Food Safety', 'Food Processing', 'Aquaculture', 'Horticulture',
  'Soil Testing', 'Pest Management', 'Organic Farming', 'Agroforestry',
  'Farm Management',

  // Health & wellness
  'Mental Health First Aid', 'Nutrition Counseling', 'Fitness Training',
  'First Aid & CPR', 'Occupational Health', 'Health Education',
  'Telemedicine', 'Clinical Research', 'Patient Care', 'Medical Coding',

  // Legal
  'Contract Law', 'Intellectual Property', 'Compliance',
  'Regulatory Affairs', 'Corporate Governance', 'Employment Law',
  'Data Privacy Law', 'Dispute Resolution', 'Legal Research',
  'Paralegal Studies',

  // Productivity tools
  'Notion', 'Slack', 'Trello', 'Asana', 'Monday.com', 'Microsoft Office',
  'Google Workspace', 'Zoom', 'Airtable', 'Jira', 'Confluence', 'Zapier',
  'HubSpot', 'Salesforce', 'Mailchimp',
];

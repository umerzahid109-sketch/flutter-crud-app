// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status Code: $statusCode)';
}

/// English course titles and descriptions for display
const List<Map<String, String>> _englishCourses = [
  {
    'title': 'Introduction to Flutter Development',
    'body':
        'Learn the basics of Flutter and Dart to build beautiful cross-platform mobile applications from scratch.'
  },
  {
    'title': 'Advanced Dart Programming',
    'body':
        'Deep dive into Dart language features including async/await, streams, generics, and advanced OOP concepts.'
  },
  {
    'title': 'UI/UX Design Principles',
    'body':
        'Understand the fundamentals of user interface and experience design to create intuitive and engaging apps.'
  },
  {
    'title': 'State Management with Provider',
    'body':
        'Master state management in Flutter using the Provider package to build scalable and maintainable applications.'
  },
  {
    'title': 'RESTful API Integration',
    'body':
        'Learn how to connect your Flutter app to backend services using HTTP requests, JSON parsing, and error handling.'
  },
  {
    'title': 'Firebase for Mobile Apps',
    'body':
        'Integrate Firebase authentication, Firestore database, and cloud storage into your Flutter applications.'
  },
  {
    'title': 'Mobile App Testing Strategies',
    'body':
        'Explore unit testing, widget testing, and integration testing techniques to ensure app quality and reliability.'
  },
  {
    'title': 'Responsive Design in Flutter',
    'body':
        'Build apps that look great on phones, tablets, and desktops using Flutter responsive layout techniques.'
  },
  {
    'title': 'Git and Version Control',
    'body':
        'Learn essential Git workflows, branching strategies, and collaboration techniques for modern software development.'
  },
  {
    'title': 'Introduction to Machine Learning',
    'body':
        'Discover the fundamentals of machine learning algorithms, data preprocessing, and model evaluation techniques.'
  },
  {
    'title': 'Python for Data Science',
    'body':
        'Use Python with pandas, NumPy, and matplotlib to analyze datasets and create meaningful visualizations.'
  },
  {
    'title': 'Web Development with React',
    'body':
        'Build dynamic and interactive web applications using React, hooks, and modern JavaScript ES6+ features.'
  },
  {
    'title': 'Database Design and SQL',
    'body':
        'Learn relational database concepts, SQL queries, joins, indexing, and database normalization principles.'
  },
  {
    'title': 'Cloud Computing with AWS',
    'body':
        'Get started with Amazon Web Services, exploring EC2, S3, Lambda, and other essential cloud services.'
  },
  {
    'title': 'Cybersecurity Fundamentals',
    'body':
        'Understand core security concepts including encryption, network security, vulnerabilities, and best practices.'
  },
  {
    'title': 'Agile Project Management',
    'body':
        'Learn Agile methodologies, Scrum framework, sprint planning, and tools to manage software projects effectively.'
  },
  {
    'title': 'Node.js Backend Development',
    'body':
        'Build robust server-side applications and REST APIs using Node.js, Express, and MongoDB.'
  },
  {
    'title': 'iOS Development with Swift',
    'body':
        'Create native iPhone and iPad applications using Swift and Xcode following Apple\'s Human Interface Guidelines.'
  },
  {
    'title': 'Android Development with Kotlin',
    'body':
        'Develop native Android apps using Kotlin, Jetpack components, and Google\'s Material Design system.'
  },
  {
    'title': 'DevOps and CI/CD Pipelines',
    'body':
        'Automate build, test, and deployment workflows using Docker, Jenkins, GitHub Actions, and Kubernetes.'
  },
  {
    'title': 'Blockchain Technology Basics',
    'body':
        'Understand how blockchain works, explore smart contracts, decentralized applications, and cryptocurrency fundamentals.'
  },
  {
    'title': 'Computer Vision with OpenCV',
    'body':
        'Process and analyze images and videos using OpenCV and Python for real-world computer vision applications.'
  },
  {
    'title': 'Natural Language Processing',
    'body':
        'Explore NLP techniques for text classification, sentiment analysis, and building conversational AI systems.'
  },
  {
    'title': 'TypeScript for Developers',
    'body':
        'Enhance your JavaScript code with TypeScript\'s static typing, interfaces, decorators, and advanced type features.'
  },
  {
    'title': 'GraphQL API Development',
    'body':
        'Design and build efficient GraphQL APIs as a modern alternative to REST for flexible data querying.'
  },
  {
    'title': 'Docker and Containerization',
    'body':
        'Package and deploy applications using Docker containers, Docker Compose, and container orchestration basics.'
  },
  {
    'title': 'Microservices Architecture',
    'body':
        'Design scalable systems using microservices patterns, service communication, and distributed system principles.'
  },
  {
    'title': 'Data Structures and Algorithms',
    'body':
        'Master essential data structures and algorithms to write efficient code and ace technical interviews.'
  },
  {
    'title': 'Object-Oriented Programming',
    'body':
        'Understand OOP pillars — encapsulation, inheritance, polymorphism, and abstraction — with practical examples.'
  },
  {
    'title': 'Functional Programming Concepts',
    'body':
        'Explore functional programming paradigms including pure functions, immutability, higher-order functions, and monads.'
  },
  {
    'title': 'Linux Command Line Basics',
    'body':
        'Become productive in the Linux terminal with file management, shell scripting, and system administration commands.'
  },
  {
    'title': 'Networking for Developers',
    'body':
        'Learn TCP/IP, DNS, HTTP/HTTPS, WebSockets, and other networking concepts essential for backend developers.'
  },
  {
    'title': 'Software Architecture Patterns',
    'body':
        'Study MVC, MVVM, Clean Architecture, and other design patterns to structure maintainable software systems.'
  },
  {
    'title': 'Kotlin Coroutines and Flow',
    'body':
        'Handle asynchronous programming in Kotlin using coroutines, Flow, and structured concurrency best practices.'
  },
  {
    'title': 'SwiftUI Modern App Design',
    'body':
        'Build declarative iOS interfaces with SwiftUI, animations, and data binding using the latest Apple frameworks.'
  },
  {
    'title': 'React Native Cross-Platform',
    'body':
        'Develop mobile apps for iOS and Android simultaneously using React Native and JavaScript.'
  },
  {
    'title': 'Vue.js Frontend Framework',
    'body':
        'Create reactive web interfaces with Vue.js, Vuex state management, and the Vue Router navigation library.'
  },
  {
    'title': 'Angular Enterprise Applications',
    'body':
        'Build large-scale enterprise web applications with Angular, RxJS, dependency injection, and TypeScript.'
  },
  {
    'title': 'Spring Boot Java Backend',
    'body':
        'Develop production-ready Java applications using Spring Boot, JPA, security, and RESTful web services.'
  },
  {
    'title': 'Django Web Framework',
    'body':
        'Build powerful web applications quickly with Django\'s ORM, authentication system, and admin interface.'
  },
  {
    'title': 'Ruby on Rails Development',
    'body':
        'Create convention-over-configuration web apps with Rails, ActiveRecord, and RESTful routing principles.'
  },
  {
    'title': 'Go Programming Language',
    'body':
        'Learn Go\'s concurrency model, goroutines, channels, and build high-performance backend services.'
  },
  {
    'title': 'Rust Systems Programming',
    'body':
        'Write safe and fast systems-level code with Rust\'s ownership model, lifetimes, and zero-cost abstractions.'
  },
  {
    'title': 'Ethical Hacking and Penetration Testing',
    'body':
        'Learn offensive security techniques to identify vulnerabilities and strengthen system defenses ethically.'
  },
  {
    'title': 'Digital Marketing Fundamentals',
    'body':
        'Understand SEO, social media marketing, email campaigns, and analytics to grow an online presence.'
  },
  {
    'title': 'Product Management Essentials',
    'body':
        'Learn how to define product roadmaps, gather user requirements, prioritize features, and launch successful products.'
  },
  {
    'title': 'UX Research Methods',
    'body':
        'Conduct user interviews, usability tests, and surveys to gather insights that drive better product decisions.'
  },
  {
    'title': 'Figma for UI Designers',
    'body':
        'Master Figma\'s design tools, prototyping features, components, and collaboration capabilities for UI design.'
  },
  {
    'title': 'Accessibility in App Development',
    'body':
        'Build inclusive applications that work for everyone, following WCAG guidelines and platform accessibility APIs.'
  },
  {
    'title': 'Performance Optimization Techniques',
    'body':
        'Analyze and improve app performance using profiling tools, lazy loading, caching, and rendering optimizations.'
  },
  {
    'title': 'Introduction to Quantum Computing',
    'body':
        'Explore the principles of quantum mechanics applied to computation, qubits, and quantum algorithms.'
  },
  {
    'title': 'AR/VR Development Basics',
    'body':
        'Get started with augmented and virtual reality development using ARKit, ARCore, and Unity.'
  },
  {
    'title': 'Game Development with Unity',
    'body':
        'Build 2D and 3D games using Unity\'s game engine, physics system, animation tools, and C# scripting.'
  },
  {
    'title': 'Arduino and IoT Projects',
    'body':
        'Program microcontrollers and connect physical sensors to the internet to build smart IoT devices.'
  },
  {
    'title': 'Raspberry Pi Development',
    'body':
        'Use the Raspberry Pi for home automation, media servers, and learning Linux-based hardware projects.'
  },
  {
    'title': 'TensorFlow Deep Learning',
    'body':
        'Build and train neural networks using TensorFlow and Keras for image recognition and predictive modeling.'
  },
  {
    'title': 'PyTorch for Research',
    'body':
        'Implement deep learning models in PyTorch for academic research and production machine learning systems.'
  },
  {
    'title': 'Data Visualization with D3.js',
    'body':
        'Create interactive and animated charts and graphs for the web using the powerful D3.js library.'
  },
  {
    'title': 'Tableau for Business Analytics',
    'body':
        'Transform raw data into insightful dashboards and visual reports using Tableau Desktop and Tableau Public.'
  },
  {
    'title': 'Excel and Power BI',
    'body':
        'Analyze business data and build interactive dashboards using Microsoft Excel formulas and Power BI visuals.'
  },
  {
    'title': 'Statistics for Data Science',
    'body':
        'Learn probability, hypothesis testing, regression analysis, and statistical inference for data-driven decisions.'
  },
  {
    'title': 'R Programming for Analysis',
    'body':
        'Use R and tidyverse packages for data wrangling, statistical computing, and publication-quality visualizations.'
  },
  {
    'title': 'Scala and Apache Spark',
    'body':
        'Process large-scale datasets with Apache Spark using Scala for big data engineering and analytics pipelines.'
  },
  {
    'title': 'Hadoop and Big Data Ecosystem',
    'body':
        'Explore HDFS, MapReduce, Hive, and the broader Hadoop ecosystem for storing and processing massive datasets.'
  },
  {
    'title': 'Kubernetes Orchestration',
    'body':
        'Deploy, scale, and manage containerized applications using Kubernetes clusters, pods, and services.'
  },
  {
    'title': 'Terraform Infrastructure as Code',
    'body':
        'Provision and manage cloud infrastructure on AWS, Azure, and GCP using Terraform configuration files.'
  },
  {
    'title': 'Ansible Automation',
    'body':
        'Automate server configuration, application deployment, and IT workflows using Ansible playbooks and roles.'
  },
  {
    'title': 'Jenkins CI/CD Automation',
    'body':
        'Set up continuous integration and delivery pipelines with Jenkins, plugins, and declarative pipeline syntax.'
  },
  {
    'title': 'Prometheus and Grafana Monitoring',
    'body':
        'Monitor application metrics, set up alerts, and visualize system health using Prometheus and Grafana dashboards.'
  },
  {
    'title': 'Elasticsearch and Kibana',
    'body':
        'Build fast search experiences and visualize log data using the Elastic Stack for observability and analytics.'
  },
  {
    'title': 'Redis Caching Strategies',
    'body':
        'Improve application performance with Redis data structures, caching patterns, pub/sub messaging, and persistence.'
  },
  {
    'title': 'PostgreSQL Advanced Queries',
    'body':
        'Go beyond basic SQL with PostgreSQL-specific features, window functions, CTEs, and performance tuning.'
  },
  {
    'title': 'MongoDB for Modern Apps',
    'body':
        'Design flexible document databases with MongoDB, aggregation pipelines, indexing, and Atlas cloud service.'
  },
  {
    'title': 'Apache Kafka Messaging',
    'body':
        'Build real-time data streaming pipelines using Apache Kafka topics, producers, consumers, and Kafka Streams.'
  },
  {
    'title': 'gRPC and Protocol Buffers',
    'body':
        'Design high-performance service communication using gRPC and Protocol Buffers for microservices architecture.'
  },
  {
    'title': 'WebAssembly Fundamentals',
    'body':
        'Explore WebAssembly to run near-native speed code in the browser using C++, Rust, or other compiled languages.'
  },
  {
    'title': 'Progressive Web Apps',
    'body':
        'Build web applications with offline support, push notifications, and native-like experience using PWA standards.'
  },
  {
    'title': 'CSS Grid and Flexbox Mastery',
    'body':
        'Create complex, responsive web layouts using modern CSS Grid and Flexbox techniques with real-world examples.'
  },
  {
    'title': 'Sass and CSS Architecture',
    'body':
        'Organize and scale stylesheets with Sass preprocessing, BEM methodology, and CSS module patterns.'
  },
  {
    'title': 'Webpack and Module Bundling',
    'body':
        'Configure Webpack to bundle JavaScript modules, optimize assets, and manage modern frontend build pipelines.'
  },
  {
    'title': 'Next.js Full-Stack Development',
    'body':
        'Build server-rendered React applications with Next.js, API routes, static generation, and deployment on Vercel.'
  },
  {
    'title': 'Nuxt.js Vue Applications',
    'body':
        'Create universal Vue.js applications with Nuxt.js for server-side rendering, routing, and static site generation.'
  },
  {
    'title': 'Svelte Modern Web Framework',
    'body':
        'Write reactive web UIs with minimal boilerplate using Svelte\'s compile-time approach and SvelteKit framework.'
  },
  {
    'title': 'Electron Desktop Apps',
    'body':
        'Build cross-platform desktop applications using web technologies like HTML, CSS, and JavaScript with Electron.'
  },
  {
    'title': 'Socket.io Real-Time Apps',
    'body':
        'Add real-time bidirectional communication to your web apps using Socket.io for chat, gaming, and live updates.'
  },
  {
    'title': 'OAuth and Authentication Flows',
    'body':
        'Implement secure authentication using OAuth 2.0, JWT tokens, OpenID Connect, and social login providers.'
  },
  {
    'title': 'Payment Gateway Integration',
    'body':
        'Add Stripe, PayPal, and other payment processors to your app with secure checkout flows and webhook handling.'
  },
  {
    'title': 'Email and Notification Systems',
    'body':
        'Build reliable email delivery, push notifications, and in-app notification systems for user engagement.'
  },
  {
    'title': 'Localization and Internationalization',
    'body':
        'Prepare your app for global audiences with multi-language support, RTL layouts, and locale-aware formatting.'
  },
  {
    'title': 'App Store Deployment Guide',
    'body':
        'Learn the complete process of publishing apps to the Apple App Store and Google Play Store successfully.'
  },
  {
    'title': 'Code Review Best Practices',
    'body':
        'Develop skills to give and receive constructive code reviews that improve code quality and team collaboration.'
  },
  {
    'title': 'Technical Writing for Developers',
    'body':
        'Write clear API documentation, README files, and technical guides that help other developers use your software.'
  },
  {
    'title': 'Open Source Contribution',
    'body':
        'Navigate GitHub, find issues to work on, submit pull requests, and become an active open source contributor.'
  },
  {
    'title': 'Freelancing for Developers',
    'body':
        'Build a freelance career by finding clients, setting rates, managing projects, and delivering quality software.'
  },
  {
    'title': 'System Design Interviews',
    'body':
        'Prepare for senior engineering interviews by designing scalable systems like social networks, file storage, and feeds.'
  },
  {
    'title': 'Clean Code Principles',
    'body':
        'Write readable, maintainable, and elegant code following SOLID principles, naming conventions, and refactoring techniques.'
  },
  {
    'title': 'Design Patterns in Practice',
    'body':
        'Apply classic Gang of Four design patterns — Singleton, Observer, Factory, Strategy — in modern software development.'
  },
  {
    'title': 'Career Growth in Tech',
    'body':
        'Navigate your software engineering career from junior to senior, staff engineer, and beyond with practical advice.'
  },
];

/// Service class for handling all API operations
/// This service communicates with JSONPlaceholder API
/// Base URL: https://jsonplaceholder.typicode.com
class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String coursesEndpoint = '/posts';

  final http.Client _client;

  ApiService() : _client = http.Client();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  /// Maps a raw API course to an English course using the lookup table
  Course _toEnglishCourse(Map<String, dynamic> json) {
    final id = (json['id'] as int? ?? 1);
    final index = (id - 1) % _englishCourses.length;
    return Course(
      id: id,
      userId: json['userId'] as int? ?? 1,
      title: _englishCourses[index]['title']!,
      body: _englishCourses[index]['body']!,
    );
  }

  /// GET: Fetch all courses from the API
  Future<List<Course>> fetchCourses() async {
    try {
      debugPrint('[API] Fetching courses from: $baseUrl$coursesEndpoint');

      final uri = Uri.parse('$baseUrl$coursesEndpoint');
      final response = await _client.get(uri, headers: _headers);

      debugPrint('[API] Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final courses = jsonData
            .map((json) => _toEnglishCourse(json as Map<String, dynamic>))
            .toList();
        debugPrint('[API] Successfully fetched ${courses.length} courses');
        return courses;
      } else {
        throw ApiException(
          'Failed to fetch courses. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[API] Error fetching courses: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching courses: $e');
    }
  }

  /// GET: Fetch a single course by ID
  Future<Course> fetchCourseById(int id) async {
    try {
      debugPrint('[API] Fetching course with ID: $id');

      final uri = Uri.parse('$baseUrl$coursesEndpoint/$id');
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final course = _toEnglishCourse(jsonData as Map<String, dynamic>);
        debugPrint('[API] Successfully fetched course: ${course.title}');
        return course;
      } else {
        throw ApiException(
          'Failed to fetch course. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[API] Error fetching course by ID: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching course: $e');
    }
  }

  /// POST: Create a new course
  Future<Course> createCourse(Course course) async {
    try {
      debugPrint('[API] Creating new course: ${course.title}');

      final uri = Uri.parse('$baseUrl$coursesEndpoint');
      final response = await _client.post(
        uri,
        headers: _headers,
        body: jsonEncode(course.toJson()),
      );

      debugPrint('[API] Response status code: ${response.statusCode}');

      if (response.statusCode == 201) {
        // JSONPlaceholder returns id=101 for new posts; preserve user's title/body
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        final newCourse = Course(
          id: jsonData['id'] as int? ?? 101,
          userId: course.userId,
          title: course.title,
          body: course.body,
        );
        debugPrint(
            '[API] Successfully created course with ID: ${newCourse.id}');
        return newCourse;
      } else {
        throw ApiException(
          'Failed to create course. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[API] Error creating course: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error creating course: $e');
    }
  }

  /// PUT: Update an existing course
  Future<Course> updateCourse(int id, Course course) async {
    try {
      debugPrint('[API] Updating course with ID: $id');

      final uri = Uri.parse('$baseUrl$coursesEndpoint/$id');
      final response = await _client.put(
        uri,
        headers: _headers,
        body: jsonEncode(course.toJson()),
      );

      debugPrint('[API] Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Preserve user's edited title/body instead of remapping
        final updatedCourse = Course(
          id: id,
          userId: course.userId,
          title: course.title,
          body: course.body,
        );
        debugPrint('[API] Successfully updated course: ${updatedCourse.title}');
        return updatedCourse;
      } else {
        throw ApiException(
          'Failed to update course. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[API] Error updating course: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error updating course: $e');
    }
  }

  /// DELETE: Delete a course by ID
  Future<bool> deleteCourse(int id) async {
    try {
      debugPrint('[API] Deleting course with ID: $id');

      final uri = Uri.parse('$baseUrl$coursesEndpoint/$id');
      final response = await _client.delete(uri, headers: _headers);

      debugPrint('[API] Response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('[API] Successfully deleted course with ID: $id');
        return true;
      } else {
        throw ApiException(
          'Failed to delete course. Status code: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      debugPrint('[API] Error deleting course: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error deleting course: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

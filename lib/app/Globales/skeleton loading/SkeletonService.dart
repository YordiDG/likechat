// lib/app/Globales/skeleton_loading/skeleton_service.dart
import 'package:flutter/material.dart';
import '../../APIS-Consumir/DaoPost/PostDatabase.dart';
import '../../home/shortVideos/Posts/PostClass.dart';
import 'SkeletonLoading.dart';


class SkeletonService {
  static Widget wrap({
    required Widget child,
    required bool isLoading,
    Widget? skeleton,
  }) {
    return isLoading ? (skeleton ?? const DefaultSkeleton()) : child;
  }

  static Future<List<Post>> getPosts() async {
    await Future.delayed(Duration(seconds: 2)); // Loading simulation
    return await PostDatabase.instance.getAllPosts();
  }
}
class DefaultSkeleton extends StatelessWidget {
  const DefaultSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SkeletonLoading(height: 20),
          SizedBox(height: 8),
          SkeletonLoading(height: 20),
          SizedBox(height: 8),
          SkeletonLoading(height: 20),
        ],
      ),
    );
  }
}
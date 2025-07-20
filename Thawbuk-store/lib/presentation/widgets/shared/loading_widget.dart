import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingWidget({
    Key? key,
    this.height,
    this.width,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightGrey,
      highlightColor: AppColors.white,
      child: Container(
        height: height ?? 200,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class ProductCardLoading extends StatelessWidget {
  const ProductCardLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            flex: 3,
            child: Shimmer.fromColors(
              baseColor: AppColors.lightGrey,
              highlightColor: AppColors.white,
              child: Container(
                width: double.infinity,
                color: AppColors.lightGrey,
              ),
            ),
          ),
          
          // Content placeholder
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingWidget(height: 16, width: 120),
                  const SizedBox(height: 8),
                  const LoadingWidget(height: 14, width: 80),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const LoadingWidget(height: 16, width: 60),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.lightGrey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListLoadingWidget extends StatelessWidget {
  final int itemCount;

  const ListLoadingWidget({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return const LoadingWidget(height: 80);
      },
    );
  }
}

class GridLoadingWidget extends StatelessWidget {
  final int itemCount;

  const GridLoadingWidget({
    Key? key,
    this.itemCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const ProductCardLoading();
      },
    );
  }
}
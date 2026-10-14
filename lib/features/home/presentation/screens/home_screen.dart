import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dummy_data.dart';
import '../../../../core/theme.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_states.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';
import '../../domain/entities/category.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(
        categoryLoader: GetCategories(context.read<HomeRepository>()),
        productLoader: GetProductsByCategory(context.read<HomeRepository>()),
      ),
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (context, state) {
        final categories = state.categories;
        final selectedId = state.selectedCategory?.id;
        final returnedLabels = categories
            .map((category) => category.displayName.toLowerCase())
            .toSet();
        final missingLabels = <String>[
          if (!returnedLabels.contains('shoes')) 'Shoes',
          if (!returnedLabels.contains('clothing')) 'Clothing',
          if (!returnedLabels.contains('accessories')) 'Accessories',
          if (!returnedLabels.contains('electronics')) 'Electronics',
        ];

        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: AppTheme.primary,
                              ),
                            ),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                dummyUser.profilePictureUrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Explore',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Best trendy collection!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search clothes...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 44,
                          child: _buildCategorySelector(
                            context,
                            state,
                            categories,
                            selectedId,
                          ),
                        ),
                        if (categories.isNotEmpty &&
                            missingLabels.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${missingLabels.join(' and ')} ${missingLabels.length == 1 ? 'is' : 'are'} not currently available from the API.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ..._buildProductContent(context, state),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySelector(
    BuildContext context,
    HomeStates state,
    List<Category> categories,
    int? selectedId,
  ) {
    if (state is CategoriesLoading || state is HomeInitial) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (state is CategoriesError) {
      return Row(
        children: [
          const Expanded(child: Text('Categories could not be loaded.')),
          TextButton(
            onPressed: () => context.read<HomeCubit>().loadCategories(),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (categories.isEmpty) {
      return const Center(child: Text('No categories are available.'));
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: categories.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryChip(
          label: category.displayName,
          isSelected: selectedId == category.id,
          onTap: () => context.read<HomeCubit>().selectCategory(category.id),
        );
      },
    );
  }

  List<Widget> _buildProductContent(BuildContext context, HomeStates state) {
    if (state is CategoriesLoading || state is HomeInitial) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is CategoriesError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ];
    }

    if (state is CategoriesSuccess && state.categories.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('The API returned no categories.')),
        ),
      ];
    }

    if (state is ProductsLoading) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (state is ProductsError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<HomeCubit>().retryProducts(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (state is ProductsSuccess && state.products.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('No products are available in this category.'),
          ),
        ),
      ];
    }

    if (state is ProductsSuccess) {
      return [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => ProductCard(product: state.products[index]),
              childCount: state.products.length,
            ),
          ),
        ),
      ];
    }

    return const [SliverToBoxAdapter(child: SizedBox.shrink())];
  }
}

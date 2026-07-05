import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bitetrack/core/di/injection.dart';
import 'package:bitetrack/core/error/failures.dart';
import 'package:bitetrack/features/business/data/repositories/business_repository.dart';
import 'package:bitetrack/features/business/domain/entities/business.dart';

class MyBusinessesPage extends StatefulWidget {
  const MyBusinessesPage({super.key});

  @override
  State<MyBusinessesPage> createState() => _MyBusinessesPageState();
}

class _MyBusinessesPageState extends State<MyBusinessesPage> {
  final _repository = getIt<BusinessRepository>();
  late Future<List<Business>> _businessesFuture;

  @override
  void initState() {
    super.initState();
    _businessesFuture = _repository.listMyBusinesses();
  }

  void _reload() {
    setState(() {
      _businessesFuture = _repository.listMyBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My businesses'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await context.push<bool>('/businesses/new');
          if (created == true) {
            _reload();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add business'),
      ),
      body: FutureBuilder<List<Business>>(
        future: _businessesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: _errorMessage(snapshot.error),
              onRetry: _reload,
            );
          }

          final businesses = snapshot.data ?? [];
          if (businesses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.storefront_outlined, size: 56, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'No businesses yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your shop or brand. You can manage multiple businesses from one account.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              itemCount: businesses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final business = businesses[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          business.logoUrl != null ? NetworkImage(business.logoUrl!) : null,
                      child: business.logoUrl == null
                          ? const Icon(Icons.storefront_outlined)
                          : null,
                    ),
                    title: Text(business.businessName),
                    subtitle: Text(_statusLabel(business)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final updated = await context.push<bool>(
                        '/businesses/${business.id}',
                        extra: business,
                      );
                      if (updated == true) {
                        _reload();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _statusLabel(Business business) {
    final verification = switch (business.verificationStatus) {
      BusinessVerificationStatus.verified => 'Verified',
      BusinessVerificationStatus.rejected => 'Rejected',
      BusinessVerificationStatus.pending => 'Pending review',
    };
    return '$verification · ${business.reviewCount} reviews';
  }

  String _errorMessage(Object? error) {
    if (error is Failure) {
      return error.message;
    }
    return 'Something went wrong';
  }
}

class CreateBusinessPage extends StatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  State<CreateBusinessPage> createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends State<CreateBusinessPage> {
  final _repository = getIt<BusinessRepository>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  List<Category> _categories = [];
  String? _categoryId;
  Uint8List? _logoBytes;
  String? _logoContentType;
  bool _loading = false;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _repository.listCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _loadingCategories = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoContentType = _contentTypeForPath(file.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final business = await _repository.createBusiness(
        businessName: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        categoryId: _categoryId,
      );

      if (_logoBytes != null && _logoContentType != null) {
        final logoUrl = await _repository.uploadImage(
          purpose: 'business_logo',
          bytes: _logoBytes!,
          contentType: _logoContentType!,
          businessId: business.id,
        );
        await _repository.updateBusiness(businessId: business.id, logoUrl: logoUrl);
      }

      if (!mounted) return;
      context.pop(true);
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New business')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickLogo,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: _logoBytes != null ? MemoryImage(_logoBytes!) : null,
                  child: _logoBytes == null ? const Icon(Icons.add_a_photo_outlined, size: 28) : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Logo (optional)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Business name',
                hintText: 'e.g. Mang Juan\'s Taho',
              ),
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Enter at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What do you sell?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_loadingCategories)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create business'),
            ),
          ],
        ),
      ),
    );
  }
}

class BusinessDetailPage extends StatefulWidget {
  const BusinessDetailPage({required this.business, super.key});

  final Business business;

  @override
  State<BusinessDetailPage> createState() => _BusinessDetailPageState();
}

class _BusinessDetailPageState extends State<BusinessDetailPage> {
  final _repository = getIt<BusinessRepository>();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _repository.listProducts(widget.business.id);
  }

  void _reload() {
    setState(() {
      _productsFuture = _repository.listProducts(widget.business.id);
    });
  }

  Future<void> _addProduct() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ProductFormSheet(
        businessId: widget.business.id,
        repository: _repository,
      ),
    );
    if (created == true) {
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.business.businessName)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Add product'),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: snapshot.error is Failure
                  ? (snapshot.error! as Failure).message
                  : 'Failed to load products',
              onRetry: _reload,
            );
          }

          final products = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            children: [
              if (widget.business.logoUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(widget.business.logoUrl!, height: 120, fit: BoxFit.cover),
                ),
              if (widget.business.description != null) ...[
                const SizedBox(height: 16),
                Text(widget.business.description!),
              ],
              const SizedBox(height: 24),
              Text('Products', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (products.isEmpty)
                Text(
                  'No products yet. Add your menu items or catalog.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              else
                ...products.map(
                  (product) => Card(
                    child: ListTile(
                      leading: product.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(product.imageUrl!, width: 48, height: 48, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.fastfood_outlined),
                      title: Text(product.name),
                      subtitle: Text(
                        product.description ??
                            '${product.currency} ${(product.priceCents / 100).toStringAsFixed(2)}',
                      ),
                      trailing: Icon(
                        product.isAvailable ? Icons.check_circle_outline : Icons.pause_circle_outline,
                        color: product.isAvailable ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  const _ProductFormSheet({
    required this.businessId,
    required this.repository,
  });

  final String businessId;
  final BusinessRepository repository;

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _imageBytes;
  String? _imageContentType;
  bool _loading = false;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageContentType = _contentTypeForPath(file.path);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final priceText = _priceController.text.trim();
      final priceCents = priceText.isEmpty
          ? 0
          : ((double.tryParse(priceText) ?? 0) * 100).round();

      final product = await widget.repository.createProduct(
        businessId: widget.businessId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        priceCents: priceCents,
      );

      if (_imageBytes != null && _imageContentType != null) {
        final imageUrl = await widget.repository.uploadImage(
          purpose: 'product_image',
          bytes: _imageBytes!,
          contentType: _imageContentType!,
          businessId: widget.businessId,
          productId: product.id,
        );
        await widget.repository.updateProduct(productId: product.id, imageUrl: imageUrl);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on Failure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('New product', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product name'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixText: '₱ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_outlined),
              label: Text(_imageBytes == null ? 'Add photo' : 'Photo selected'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save product'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

String _contentTypeForPath(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

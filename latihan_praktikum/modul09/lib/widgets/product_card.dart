
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../helpers/hive_helper.dart';
import '../models/produk.dart';

class ProductCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback onTambah;
  final VoidCallback onFavorit;

  const ProductCard({
    super.key,
    required this.produk,
    required this.onTambah,
    required this.onFavorit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder(
      valueListenable: HiveHelper.box.listenable(),
      builder: (context, box, _) {
        final sudahFavorit = box.containsKey(produk.id);

        return Card(
          child: ListTile(
            title: Text(
              produk.nama,
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Rp${produk.harga}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    sudahFavorit
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: sudahFavorit ? Colors.red : null,
                  ),
                  tooltip: sudahFavorit
                      ? 'Sudah menjadi favorit'
                      : 'Tandai favorit',
                  onPressed: sudahFavorit ? null : onFavorit,
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: onTambah,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

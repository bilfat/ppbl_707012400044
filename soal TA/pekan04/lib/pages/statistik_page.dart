import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/pengajuan_model.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PengajuanModel>();

    final administrasi =
        model.jumlahBidang('Administrasi Kependudukan');

    final kesehatan =
        model.jumlahBidang('Kesehatan');

    final perizinan =
        model.jumlahBidang('Perizinan');

    final sosial =
        model.jumlahBidang('Sosial');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Layanan'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BarChart(
          BarChartData(
            maxY: 10,

            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text;

                    switch (value.toInt()) {
                      case 0:
                        text = 'Adm';
                        break;
                      case 1:
                        text = 'Sehat';
                        break;
                      case 2:
                        text = 'Izin';
                        break;
                      case 3:
                        text = 'Sosial';
                        break;
                      default:
                        text = '';
                    }

                    return Text(text);
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                ),
              ),

              topTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),

              rightTitles: const AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
            ),

            barGroups: [
              BarChartGroupData(
                x: 0,
                barRods: [
                  BarChartRodData(
                    toY: administrasi.toDouble(),
                    width: 30,
                  ),
                ],
              ),

              BarChartGroupData(
                x: 1,
                barRods: [
                  BarChartRodData(
                    toY: kesehatan.toDouble(),
                    width: 30,
                  ),
                ],
              ),

              BarChartGroupData(
                x: 2,
                barRods: [
                  BarChartRodData(
                    toY: perizinan.toDouble(),
                    width: 30,
                  ),
                ],
              ),

              BarChartGroupData(
                x: 3,
                barRods: [
                  BarChartRodData(
                    toY: sosial.toDouble(),
                    width: 30,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  List<Compan> _watchlist = [];
  @override
  void initState() {
    super.initState();
    _loadWatchlist();
  }

  void _loadWatchlist() async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'watchlist.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE IF NOT EXISTS watchlist (symbol TEXT PRIMARY KEY, name TEXT)',
        );
      },
    );

    final rows = await database.query('watchlist');
    final companies = rows.map((row) => Compan.fromJson(row)).toList();

    setState(() {
      _watchlist = companies;
    });

    await database.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadWatchlist();
        },
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _watchlist.length,
                itemBuilder: (context, index) {
                  final company = _watchlist[index];
                  return ListTile(
                    title: Text(company.name),
                    subtitle: Text(company.symbol),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _removeFromWatchlist(company);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromWatchlist(Compan company) async {
    final databasePath = await getDatabasesPath();
    final database = await openDatabase(
      join(databasePath, 'watchlist.db'),
      version: 1,
    );

    await database.delete(
      'watchlist',
      where: 'symbol = ?',
      whereArgs: [company.symbol],
    );

    await database.close();

    setState(() {
      _watchlist.remove(company);
    });
  }
}

class Compan {
  final String symbol;
  final String name;

  Compan({required this.symbol, required this.name});

  factory Compan.fromJson(Map<String, dynamic> json) {
    return Compan(
      symbol: json['symbol'],
      name: json['name'],
    );
  }
}

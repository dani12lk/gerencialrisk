import 'package:flutter/material.dart';

void main() {
  runApp(const DJDealflowApp());
}

class DJDealflowApp extends StatelessWidget {
  const DJDealflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DJ Dealflow Trading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const TradingHomePage(),
    );
  }
}

class TradingHomePage extends StatefulWidget {
  const TradingHomePage({super.key});

  @override
  State<TradingHomePage> createState() => _TradingHomePageState();
}

class _TradingHomePageState extends State<TradingHomePage> {
  final List<Map<String, dynamic>> _trades = [];
  final TextEditingController _assetController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  String _type = 'Compra (Call)';

  void _addTrade() {
    if (_assetController.text.isEmpty || _profitController.text.isEmpty) return;
    
    setState(() {
      _trades.add({
        'asset': _assetController.text.toUpperCase(),
        'type': _type,
        'profit': double.tryParse(_profitController.text) ?? 0.0,
      });
    });

    _assetController.clear();
    _profitController.clear();
    Navigator.pop(context);
  }

  double get _totalProfit {
    return _trades.fold(0.0, (sum, item) => sum + (item['profit'] as double));
  }

  void _showAddTradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Registar Nova Operação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _assetController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Ativo (ex: EUR/USD, BTC)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _type,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  items: ['Compra (Call)', 'Venda (Put)'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _type = newValue!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Operação',
                    labelStyle: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _profitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Resultado / Lucro (€ ou \$)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _addTrade,
                  child: const Text('Salvar Operação', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DJ Dealflow Trading'),
        backgroundColor: const Color(0xFF1F1F1F),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _totalProfit >= 0 ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                const Text('Lucro / Prejuízo Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  '${_totalProfit >= 0 ? '+' : ''}${_totalProfit.toStringAsFixed(2)} €',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _totalProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Histórico de Operações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
          Expanded(
            child: _trades.isEmpty
                ? const Center(
                    child: Text('Sem operações registadas ainda.', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _trades.length,
                    itemBuilder: (context, index) {
                      final trade = _trades[index];
                      final isProfit = (trade['profit'] as double) >= 0;
                      return Card(
                        color: const Color(0xFF1E1E1E),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isProfit ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                            child: Icon(
                              isProfit ? Icons.arrow_upward : Icons.arrow_downward,
                              color: isProfit ? Colors.greenAccent : Colors.redAccent,
                            ),
                          ),
                          title: Text(trade['asset'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(trade['type'], style: const TextStyle(color: Colors.grey)),
                          trailing: Text(
                            '${isProfit ? '+' : ''}${trade['profit'].toStringAsFixed(2)} €',
                            style: TextStyle(
                              color: isProfit ? Colors.greenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showAddTradeModal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
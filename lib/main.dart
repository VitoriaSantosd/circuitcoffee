import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const supabaseUrl = 'https://pouexwwhwxnuzoxvnejb.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBvdWV4d3dod3hudXpveHZuZWpiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTUxNjgyMzEsImV4cCI6MjAzMDc0NDIzMX0.X6VmW9b-dtkKHAugIpN9U_yFaB4evhOaZ0cMVVsMlgs';

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Circuit Coffee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AddPedidoScreen(),
    );
  }
}

class AddPedidoScreen extends StatefulWidget {
  @override
  _AddPedidoScreenState createState() => _AddPedidoScreenState();
}

class _AddPedidoScreenState extends State<AddPedidoScreen> {
  TextEditingController _clienteController = TextEditingController();

  @override
  void dispose() {
    _clienteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Pedido'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _clienteController,
              decoration: InputDecoration(
                labelText: 'Nome do Cliente',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addPedido(_clienteController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Pedido adicionado com sucesso!'),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4ABEFF),
              ),
              child: Text(
                'Adicionar Pedido',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPedido(String nomeCliente) async {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyy-MM-dd').format(now);

    final pedido = {
      'id': Uuid().v4(),
      'Bebida': 'Café',
      'Acompanhamento': 'Acompanhamento',
      'StatusPedido': 'Aguardando', // ou 'Aprovado' ou 'Cancelado'
      'DataPed': formattedDate,
      'NomeCli': nomeCliente,
    };

    final response = await Supabase.instance.client
        .from('core_pedido')
        .insert([pedido]).then((value) => value);

    if (response.error != null) {
      throw response.error!;
    }
  }
}

class VisualizarPedidosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pedidos em Aguardo',
          style: TextStyle(
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _getPedidos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os pedidos'));
          }
          final pedidos = snapshot.data as List<dynamic>;
          return ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return ListTile(
                title: Text(
                  pedido['NomeCli'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                subtitle: Text(
                  'Status: ${pedido['StatusPedido']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getPedidos() async {
    final response = await Supabase.instance.client
        .from('core_pedido')
        .select('*')
        .order('Data', ascending: false);
    return response;
  }
}

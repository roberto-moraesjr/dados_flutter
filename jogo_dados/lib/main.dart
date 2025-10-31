// Importa a biblioteca para trabalhar com números aleatórios (para o dado)
import 'dart:math';
//Importa o pacote principal do Flutter (widgets, design...etc)
import 'package:flutter/material.dart';

// 1. ESTRUTURA BASE DO APP
//A função principal que inicia o app
void main() => runApp(const AplicativoJogodeDados());

//Raiz (base) do app. Definir o tema e o fluxo inicial
class AplicativoJogodeDados extends StatelessWidget {
  const AplicativoJogodeDados({super.key});

  @override
  Widget build(BuildContext context) {
    //fazer um return do MaterialApp, que dá o visual ao projeto
    return MaterialApp(
      title: 'Jogo de Dados', //Título que aparece no gerenciador
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TelaConfiguracaoJogadores(),
    );
  }
}

//  2. TELA DE CONFIGURAÇÃO DE JOGADORES
// Primeira tela do app. Coletar os nomes dos jogadores
class TelaConfiguracaoJogadores extends StatefulWidget {
  const TelaConfiguracaoJogadores({super.key});

  @override
  //cria o objeto de Estado que vai gerenciar o formulário do jogador
  State<TelaConfiguracaoJogadores> createState() =>
      _EstadoTelaConfiguracaoJogadores();
}

class _EstadoTelaConfiguracaoJogadores
    extends State<TelaConfiguracaoJogadores> {
  //Chave Global para identificar e validar o widget
  //final é uma palavra chave do dart para criar uma variável que só recebe valor uma vez
  //FormState é o estado interno desse formulário, é a parte que sabe o que está digitado e consegue
  //validar os campos
  final _chaveFormulario = GlobalKey<FormState>();
  //Controladores para pegar o texto digitado nos campos
  final TextEditingController _controladorJogador1 = TextEditingController();
  final TextEditingController _controladorJogador2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuração dos Jogadores")),
      body: Padding(
        padding: const EdgeInsets.all(16), //Espaçamento Interno
        child: Form(
          key: _chaveFormulario, //Associando a chave GlobalKey ao formulário
          child: Column(
            children: [
              //Campo de texto para o Jogador nº1
              TextFormField(
                controller: _controladorJogador1, //liga o input ao controlador
                decoration: const InputDecoration(labelText: "Nome Jogador 1"),
                validator: (valor) => valor!.isEmpty ? "Digite um nome" : null,
                // condição ? valor_se_verdadeiro : valor_se_falso
                //Se o campo estiver vazio, mostre o texto Digite um nome.
              ),
              const SizedBox(height: 16),
              //Campo de texto para o Jogador nº2
              TextFormField(
                controller: _controladorJogador2, //liga o input ao controlador
                decoration: const InputDecoration(labelText: "Nome Jogador 2"),
                validator: (valor) => valor!.isEmpty ? "Digite um nome" : null,
                // condição ? valor_se_verdadeiro : valor_se_falso
                //Se o campo estiver vazio, mostre o texto Digite um nome.
              ),
              const Spacer(), //Ocupar o espaço vertical disponível, empurrando o botão p/ baixo
              //Fazer um botão para iniciar o jogo
              ElevatedButton(
                onPressed: () {
                  //Checar se o formulário está válido(se os campos foram preenchidos)
                  if (_chaveFormulario.currentState!.validate()) {
                    //Navega para a próxima tela
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        //Cria a tela do jogo, PASSANDO os nomes digitados como Parâmetros.
                        builder: (context) => TelaJogodeDados(
                          nomeJogador1: _controladorJogador1.text,
                          nomeJogador2: _controladorJogador2.text,
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                //Botão de largura total.
                child: const Text("Iniciar Jogo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//3. TELA PRINCIPAL DO JOGO

// Aqui eu vou receber os nomes como propriedades
class TelaJogodeDados extends StatefulWidget {
  //Variáveis finais que armazenam os nomes recebidos da tela anterior
  final String nomeJogador1;
  final String nomeJogador2;
  //TELAJOGODEDADOS é o corpo de um robô
  const TelaJogodeDados({
    super.key,
    //o required garante que esses valores devem ser passados.
    required this.nomeJogador1,
    required this.nomeJogador2,
  });

  @override
  //Ei tio flutter, quando essa tela for criada, use essa classe chamada _EstadoTelaJogoDeDados
  // para guardar e controlar o estado dela
  //ESTADOTELAJOGODEDADOR é o cérebro do robô que guarda o que está acontecendo.
  //o createstate é o botão que coloca o cérebro dentro do robô
  State<TelaJogodeDados> createState() => _EstadoTelaJogoDeDados();
}

class _EstadoTelaJogoDeDados extends State<TelaJogodeDados> {
  final Random _aleatorio = Random(); //gerador de números aleatórios
  //Lista dos 3 valores de cada jogador.
  List<int> _lancamentosJogador1 = [1, 1, 1];
  List<int> _lancamentosJogador2 = [1, 1, 1];
  String _mensagemResultado = ''; //Mensagem de resultado da rodada.

  //Mapear as associações do número dado referente ao link
  final Map<int, String> imagensDados = {
    1: 'https://i.imgur.com/1xqPfjc.png',
    2: 'https://i.imgur.com/5ClIegB.png',
    3: 'https://i.imgur.com/hjqY13x.png',
    4: 'https://i.imgur.com/CfJnQt0.png',
    5: 'https://i.imgur.com/6oWpSbf.png',
    6: 'https://i.imgur.com/drgfo7s.png',
  };

  /// Lógica da pontuação: verifica combinações para aplicar os multiplicadores.
  int _calcularPontuacao(List<int> lancamentos){
    //reduce percorre toda a lista somando tudo
    final soma = lancamentos.reduce((a,b) => a + b);
    // [4,4,1] > 4 + 4 = 8 > 8 + 1 = 9 > soma = 9
    final valoresUnicos = lancamentos.toSet().length;
    //toSet remove repetidos 
    if (valoresUnicos == 1){ //Ex: [5,5,5]. Três iguais = 3x a soma
      return soma * 3;
    } else if (valoresUnicos == 2) { //Ex: [4,4,1] Dois iguais = 2x a soma
      return soma * 2;
    } else {// Ex: [1,3,6]. Todos diferentes = soma pura.
      return soma;
    }
  }
  //Função chamada pelo botão para lançar os dados
  void _lancarDados(){ //eu uso o sublinhado _ significa que ela é privada, só pode ser usada
  //dentro dessa classe
  // comando crucial p/ forçar a atualização da tela
    setState(() {
      _lancamentosJogador1 = List.generate(3, (_) => _aleatorio.nextInt(6) + 1);
      _lancamentosJogador2 = List.generate(3, (_) => _aleatorio.nextInt(6) + 1);

      final pontuacao1 = _calcularPontuacao(_lancamentosJogador1);
      final pontuacao2 = _calcularPontuacao(_lancamentosJogador2);

      if (pontuacao1 > pontuacao2 ){
        _mensagemResultado = '${widget.nomeJogador1} venceu! ($pontuacao1 x $pontuacao2)';
      } else if (pontuacao2 > pontuacao1) {
        _mensagemResultado = '${widget.nomeJogador2} venceu! ( $pontuacao2 x $pontuacao1)';
      } else {
        _mensagemResultado = 'Empate! Joguem novamente.';
      }
    });
  }
 // declara a função que devolve um widget: recebe nome jogador, lancamentos: os 3 valores do dado
Widget _construirColunaJogador(String nome, List<int> lancamentos) {
  return Expanded( // pega todo o espaço disponível dentro de um row ou column
    child: Column(
      children: [
        Text(
          nome,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // é o justify-content:center do css
          children: lancamentos.map((valor) {
            // map transforma o número do dado em um widget de imagem
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.network(
                imagensDados[valor]!, // pega a url do mapa usando o 'valor' do dado
                width: 50,
                height: 50,
                errorBuilder: (context, erro, stackTrace) =>
                    const Icon(Icons.error, size: 40),
              ),
            );
          }).toList(), // converte o resultado de volta para uma lista de widgets
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text('Jogo de Dados')),
      body: Column(
        children: [
          Row(
            children: [
              _construirColunaJogador(widget.nomeJogador1, _lancamentosJogador1),
              _construirColunaJogador(widget.nomeJogador2, _lancamentosJogador2),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _mensagemResultado,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Spacer(), //Empurra o botão para a parte de baixo da tela.
          ElevatedButton(
            onPressed: _lancarDados,
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            child: const Text('Jogar Dados'),
          )
        ],
      )
    );
  }


}



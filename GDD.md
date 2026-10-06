## Sobre este projeto

Este é um jogo simples que vai ser usado como exemplo para um minicurso de composição de música e 
efeitos sonoros para jogos. Você vai construir um jogo simples e 100% funcional, utilizar as musicas e 
efeitos sonoros pre-existentes nos assets e deixar de uma forma simples para os alunos substituirem por
suas proprias criações, o objetivo aqui é dar a oportunidade para eles verem suas criações sendo usadas
dentro de um contexto adequado para auto avaliação e auto crítica.

## O projeto: Jogo de Space Shooter

Este projeto é um jogo do tipo "shoot'em up", ou seja, um jogo de tiro vertical, em que o jogador controla
uma nave pelo espaço sideral.

## Cenas

O jogo possui somente uma cena principal com vários estados possiveis:

- Cena inicial: A logo do jogo com uma mensagem "aperte para iniciar" piscando enquanto o plano de fundo se move
junto com outros elementos para dar a impressão que o cenário é o espaço sideral.
- Cena principal (o gameplay): O jogador controla uma nave (especificamente a nave da imagem localizada em ships/2.png) que
pode se mover nas 8 direções (norte, sul, leste, oeste, noroeste, nordeste, sudoeste e sudeste) ao apertar as teclas ou
um conjunto de teclas. O jogador pode fazer a nave atirar ao apertar (ou manter pressionado) a tecla "Z", e é disparado tiros
da imagem shots/1.png. Este é o tiro inicial, e mais tiros podem ser obtidos a medida que o jogador vai coletando "powerups" (mais informações abaixo)
- Cena de game over: Uma vez que a barra de vida da nave é "secada" (ou seja, chega a zero), a nave explode, e aparece a mensagem de
"game over" na tela, junto com o jigle de game over, o plano de fundo continua se movendo e o jogador tem a opção de recomeçar ou volta a tela
de inicio (vai aparecer estas opções posteriormente para ele apos a musica de game over terminar de tocar). Alem disso, as 10 maiors pontuações 
aparecem, tal qual um jogo de arcade faria.

## As "Ondas de inimigos" (waves)

O jogo se desenrola em várias "ondas", nas quais cada uma tem os inimigos ou obstáculos a serem superados.

- Onda 1: Background comum (alternando entre as imagens backgrounds/1.png e 2.png que scrollam infinitamente e alternam entre si para mostrar coisas diferentes),
os inimigos que aparecem são os "astronautas do mal" (imagem ships/5.png), eles inicialmente estao fora da tela (posição y < 0, tipo uns -200) e aparecem junto
com o scroll do background. Eles se movem horizontalmente apenas, para alinhar a sua posição X com a posição X do jogador, (e assim atirar para acerta-lo).
Muito cuidado, pois se houver mais de um astronauta do mal na mesma "linha", eles não se sobrepõem para atirarem no jogador, eles colidem e ficam lado a lado.
O seu tiro é a imagem shots/7.png invertida, pois e necessario para nao causar um efeito estranho, ja que o tiro esta vindo na direção contraria do jogador.
O jogador possui 10 de HP, e o tiro do astronauta causa 1 de dano. O astronauta possui 5 de HP, então sao necessario 5 tiros do jogador no nivel 1 do tiro para mata-lo.
Quando o astronauta morre, soa o efeito sonoro de morte e toca-se o efeito da sequencia de imagens effects/1.gif (sera necessario extrair os frames individuais e montar
uma animação). Existe 10% de chance de um astronauta, ao seu destruido gere um item de recompensa, este item pode ser alguma gema que confere quantidades diferentes
de pontos pro jogador. Existem 4 imagens animadas de gems na pasta items que vão de gem-1.png ate gem-4.png, elas são cada uma uma spritesheet, entao analise
como fazer a animação delas. Qualquer item simplesmente desce vagarosamente (mudança da posição y adicionando frame a frame) e, se nao for coletada (ou seja
o colisor do jogador chocar no colisor do item), quando ele sumir da tela (ou seja, ultra passar o height da tela, ele desaparece). Cada gema uma quantidade de
pontos extras, a gem mais basica dá 100 pontos e a ultima gem dá 10 vezes mais a quantidade da primeira, crie uma curva de subida para as outras. Os astronautas do
mal nao se deslocam pra um Y superior a 25% do tamanho da tela, eles ficam lá se movendo sempre na direção a se alinhar ao X do jogador, atirando em intervalos,
ou seja, eles tem um cooldown entre um tiro e outro (cooldown de 3 segundos a cada tiro).

- Onda 2: Background alternando entre 2, 3 e 4, para dar uma noção de que o usuario esta chegando em dimensões longuinquas, longe de onde ele iniciou sua
jornada. Os inimigos aqui são dois. Os já conhecidos astronautas do mal, mas agora vem um novo: os "polvos do mal", eles são a imagem ships/10.png. Eles aparecem
de fora da tela (ou seja y < 0), e timidamente vão se deslocando pra baixo, mas depois de descer 30% da tela, eles começam a se deslocar em direção a nave do jogador
e caso se choquem com o jogador, eles explodem e causam dano no jogador, retirando 2 pontos de HP. Inicialmente eles vem em poucas quantidades, mas a medida que
o jogador vai avançando a quantidade de polvos vai aumentando, e a quantidade de astronautas vai diminuindo ate que os astronautas nao vem mais e so vem polvos,
isso é um preludio para o primeiro boss, que tambem é um polvo, mas é um polvo gigante. A quantidade maxima de polvos gerados é 10 de uma vez so, as waves tambem
tem um cooldown, mas em relação aos polvos, esse cooldown vai sendo diminuindo a medida que o boss vai se aproximando. Cada polvo tem 2 de vida. Depois de uma
quantidade significativa de polvos, o boss aparece (ver seção de bosses)

- Onda 3: Background de scroll infinito, somente a imagem background/5.png ja que esta é a onda da chuva de meteoros. Nesta onda a tela é abarrotada de asteroides
e tudo mais que restou da criação do universo. Precisam ser gerados os elementos de imagens background/meteor-1.png, meteor02.png, meteor-3.png, meteor-4.png e 
meteor-5.png. Se um meteoro se chocar com o jogador, ele se destroi mas gera dano no jogador. O meteor-1 gera 4 de dano (ja que e maior) e o meteor-2 gera 2 de dano.
O meteor-3 gera 3 de dano, o meteor-4 gera 2 de dano e o meteor-5 gera 1 de dano. Cada meteor pode ou não, ao ser destruido gerar outros meteors menores, abaixo
esta a lista com as informações:

- Meteor-1 HP: 10, gera 2 meteor-2 1 na direção do jogador e outro numa direção aleatória ao ser destruido, velocidade: muito lento
- Meteor-2: HP: 6, nao gera nada ao ser destruido, velocidade: lento
- Meteor-3: HP 5, gera, 4 meteor-4 em direções aleatorias ao ser destruido, velocidade: moderada
- Meteor-4: HP: 3, gera 6 meteor-5 em direções aleatorias ao ser destruido, velocidade: rápida

Essa onda é dividida em 3 partes:
- Parte 1: Sao gerados exclusivamente meteor-1 e meteor-2, alem dos gerados via destruição de maiores
- Parte 2: Sao gerados exclusivamente meteor-3, meteor-3 e meteor-5, alem dos gerados via destruição de maiores
- Parte 3: sao gerados todos os meteoros, um caos total, já que é a parte final

Regra geral: Independente da onda, sempre vai vir ao menos 1 onda de recompensa


## Ondas de recompensa

Periodicamente, entre uma onda e outra, vem uma onda de recompensa, ou seja, uma onda com items beneficos pro jogador recarregar. Existe alguns tipos de ondas
beneficas:

- Ondas de crates: Sao ondas que vem o item do tipo "crate" (imagens items/crate-1.png e create-2.png). Essas crates sao caixas que devem ser destruidas
pelo jogador, ao serem destruidas, elas liberam varios itens beneficos, gems, powerups, rockets e etc. A crate 1 (marrom) é mais comun e mais simples, gera
80% das vezes gemas (de 2 a 4 gemas) e 20% das vezes gera 6 gemas e 1 powerup aleatorio (ver a seção de powerups). A crate-2 (azul) é mais rara, ela, ao ser
destruida, gera de 10 a 20 gemas e 2 powerups aleatorios. Cada crate tem 15 pontos de HP. Ao ser destruida gera um efeito de destruição pode ser o effects/5.gif (que na verdade é o fx5.png)
- Ondas de benefactor ship: Dentro de uma mesma onda de inimigos, existe uma pausa em que acontece uma breve calmaria (ou seja os inimigos nao sao gerados) e
aparece uma nave espacial amiga que lança powerups aleatorios, podem ser qualquer um dos powerups ou gemas. Ela aparece de baixo pra cima e quando chega a 20% da posição 0 do Y
( ou seja proximo de sumir da tela) ela lança os items beneficos aleatorios. A immagem da nave benfeitora é a ships/6.png

## Os Bosses

- O polvo gigante: É o chefe da onda 2. Ele é a imagem ships/9.png. Ele tem alguns padrões de movimento que são acionados aleatoriamente. O primeiro é ele chegando.
Ele chega numa velocidade acima do normal e fica no centro da tela em relação a posição X mas com um Y pequeno, cerca de 50, para nao atacar o heroi inicialmente.
Ele sempre tem um movimento idle que oscila para cima e para baixo, como uma onda seno, ja que ele nao tem animação e tem alguns padroes de movimento que são
os seus ataques:
    - Padrao 1: Escolhe aleatoriamente um dos 4 cantos da tela, move-se para lá e, fica disparando (spawnando) polvos pequenos do seu proprio corpo. Uma regra geral
    para este boss é que sempre que ele se move, ele gera afterimagens, que são aquelas imagens iguais a eles, feitas com shader, igual ao que acontece com o alucard
    de castlevania SOTN, para dar um efeito dramático ao boss, todos os outros bosses fazem o mesmo e pode-se criar um componente reutilizavel com isso. O vetor dos
    polvos pequenos gerados é aleatório, o objetivo do boss e tentar, aleatoriamente acertar o jogador. Ele se move de forma circular depois que chegou no canto que foi
    escolhido aleatoriamente, em movimento horario ou anti-horario, tambem escolhido aleatoriamente.
    - Padrao 2: ele fica no centro da tela, e começa a "tremer" (a sua posição alterna aleatoriamente em X e Y em poucas unidades 1 ou 2 pixels, mas sempre volta pro centro),
    e nessa "tremedeira" ele atira polvos pequenos sequenciais, esse tiro começa a dar a volta em torno de si, de forma que o jogador precisa continuar atirando nessse
    boss para vence-lo mas precisa fazer movimentos em volta dele para escapar desses tiros sequenciais (é o mesmo padrao de um chefe do jogo contra 3 de SNES, aquele que
    aparece "abrindo" a parede com as mãos e tem um padrao de tiro que força o usuario a ficar girando pela tela para nao ser atingido)
Este chefe tem 400 de HP (ou uma quantidade razoável para forçar 3 minutos de batalha), quando ele morre, toca o efeito de morte (ou explosao) enquanto ele vai sumindo
e toca o efeito effects/explosion.gif em varios pontos dele (cuidado com a transparencia) (acho que é o fx-7.png, ele tem a spritesheet)

- Boss final: Acontece apos o fim da onda 3, a chuva de meteoros, primeiramente vem uma parte bonus com 2 ou 3 ondas de recompensa aleatorias e em seguida o background
muda para o backgrounds/1.png novamente e o boss chega. A imagem do boss é a ships/7.png. Quando ele chega, a musica muda, é a musica mais ameaçadora de todas,
ele se movimenta sempre com o shader de afterimagens que existe no boss anterior. Ele atira dos dois canhões que ele possui nas mãos, que podem ser os tiros
shots/11.png ou 8.png. Os padrões de ataque dele estão descritos abaixo:
    - Padrao 1: Ele vai girando para o canto inferior esquerdo, e, apontando os canhões para a direita, ele atira um feixe de luz parecido com um kame-hame-ha que atinge toda
    a extensão da tela, e, com esse tiro ativado, ele sobe até 20% da altura da tela (contando do zero, cerca de 100px no Y), a unica forma do jogador se esquivar é 
    movendo sua nave pra cima, ele se move numa velocidade relativamente veloz. (Nao tem neste momento nos assets uma imagem para esse feixe de luz, tente encontrar uma forma
    de fazer isso com as imagens dos shots que existem nos resources ou fazer isso programativamente, se tudo mais der errado, faça-o atirar rapidamente de forma que
    se o jogador tiver no raio dos tiros, naturalmente ele vai ser atingido)
    - Padrão 2- Similar ao padrão 1, mas ele se move girando ate o canto superior direito, e atira se movendo da direita para a esquerda, parando a 20% da posição X
    (ouseja, cerca de 100px de posição X, para dar uma posição que o jogador consiga esquivar do ataque, mas somente se ele prever o movimento e ja ir se deslocando para lá,
    com antecedência)
    - Padrão 3 - Ele fica no meio, cria dois clones de "after images" que ficam piscando (quase "tentando" existir) e atiram cada um na sua posição
    - Padrao 4 - Ele fica se movendo da direita para a esquerda, e, em um momento aleatorio, ele sincroniza o seu X com o X do jogador e atira nele.

O boss fica aleatoriamente fazendo esses padroes ate matar o jogador ou ser morto por ele. Se o jogador matar o boss final, é fim de jogo e ele venceu.

## Background

É o scroll infinito tipico de jogos shmup, alem das orientações de cada onda, podem, aleatoriamente e onde couber, ser gerados estrelas que scrollam como
as imagens backgrounds/planet-2.png star-1.png star-2.png moon.png planet-1.png so tomar cuidado pra eles nao estarem muito proximos das imagens que ja 
existem dentro de alguns backgrounds (3, 4 e 2)

## Os powerups

Vou agora listar alguns powerups que nao foram ainda descritos (ja que alguns foram descritos na seção das ondas)

- items/power-up-1: recupera 5 de HP do jogador
- items/power-up-2.png aumenta em 1 unidade o item "Bomba" no inventario do jogador
- items/power-up-3.png aumenta em 1 unidade o item "Rocket (foguete)" no inventario do jogador
- items/power-up-4.png aumenta em 1 unidade o atributo (velocidade) do jogador (ou seja, sua nave anda mais rapido)

## O inventario e os efeito dos seus items

- Bomba: a bomba é a imagem items/bomb.png que é atirada pelo jogador ao ser selecionada (o jogador atira com Z mas pode mudar a arma com a telca X, se ele escolher a bomba
ele atira a bomba e esta, depois de 1 segundo ao ser atirada, gera um circulo explosivo que destroi tudo o que estiver dentro dele, este efeito e gerado via
programação com geometria, a bomba alterna de cor com cores quentes que lembram explosoes e a cada tick do frame ela dá 2 pontos de dano, o suficiente para
matar inimigos fracos e dar um dano significado em bosses)
- Foguete (Rocket) - O foguete são tiros teleguiados, ou seja, eles identificam os inimigos que existem na tela no momento e vão em sua direção de forma
imediata quando são atirados, eles são bem velozes e causam 4 pontos de dano no HP do alvo. Quando o jogador obtem o item "rocket" ou foguete, ele ganha
20 unidades (ou seja 20 "balas") desse equipamento.

## HUD

Para dar informação visual pro jogador, sao utilizados alguns elementos fixos na tela. 

- Barra de energia, é mostrada usando as imagens hud/energy-bar.png energy-bar-fill.png health-bar.png health-bar-fill.png life-empty.png e life-full.png
- Quantidade de vidas: e usado a imagem hud/lives-icon.png que demostra a quantidade de vezes que o jogador pode "morrer" antes de dar game over
e o jogo voltar pro começo. O jogador ganha 1 vida a cada 10.000 pontos. Quando ele morre a vida volta completamente cheia.

Decisão por hora, so se deve mostrar a barra de health, ja que nao foi criado nada pra barra de energia.

## Fontes

Use a imagem font-20x20.png para fazer a logo do jogo (SPACE SHOOTER) e escolha uma fonte boa para jogos shmup para os demais dialogos (como por exemplo
a mensagem que pisca "aperte enter para iniciar")

Quando aparecer os recordes, estilo arcade o jogador escolhe as 3 letras para definir o seu registro, e mostra as 10 maiores pontuaões (dedica quais)
e use a fonte font-20x20.png para mostrar os numeros e escolher as letras. O input das letras funciona igual um jogo arcade, o jogador usa as setas
para cima ou para baixo para "aumentar" ou diminui a posição das letras (por exemplo, se ele esta em A e aperta pra cima, ele vai pra B e assim sucessivamente)
E registra seu recorde





# Como colocar as suas músicas e efeitos sonoros no jogo

Todo o áudio do jogo está ligado em **um único arquivo**: `res://audio/sound_bank.tres`.
Você não precisa mexer em nenhuma linha de código.

## Passo a passo

1. Copie o seu arquivo de áudio para dentro do projeto (por exemplo, para uma pasta `res://meus-sons/`).
   - Músicas: prefira **.ogg**.
   - Efeitos sonoros: **.wav** ou **.ogg**.
2. No Godot, dê dois cliques em `audio/sound_bank.tres`. Ele abre no **Inspector**.
3. Encontre o evento que você quer trocar (eles estão agrupados: Músicas, Jogador, Itens...).
4. Arraste o seu arquivo do painel **FileSystem** para o campo do evento.
5. Salve (Ctrl+S) e rode o jogo (F5).

Para deixar um evento em silêncio, clique na setinha do campo e escolha **Clear**.

## Testando rápido

Na tela inicial (rodando pelo editor), as teclas abaixo pulam direto para uma parte do jogo:

| Tecla | Parte do jogo | Música |
|-------|---------------|--------|
| F1 | Onda 1: astronautas do mal | `music_wave_1` |
| F2 | Onda 2: astronautas e polvos | `music_wave_2` |
| F3 | Chefe: polvo gigante | `music_boss` |
| F4 | Onda 3: chuva de meteoros | `music_wave_3` |
| F5 | Bônus (ondas de recompensa) e chefe final | `music_wave_3`, depois `music_boss` |
| F6 | Chefe final | `music_boss` |

As teclas F1 a F6 também funcionam durante o jogo. ESC pausa.

## Os eventos

### Músicas (tocam em loop)
| Evento | Quando toca |
|--------|-------------|
| `music_wave_1` | Onda 1 |
| `music_wave_2` | Onda 2 |
| `music_wave_3` | Onda 3 (chuva de meteoros) |
| `music_boss` | Os dois chefes |

A tela inicial, o game over e o ranking ficam em silêncio de propósito.

### Efeitos sonoros
| Evento | Quando toca | Dica |
|--------|-------------|------|
| `player_shoot` | Cada tiro da nave | Toca ~8 vezes por segundo: deve ser **bem curto** |
| `player_hit` | A nave levou dano | |
| `player_death` | A nave explodiu | |
| `weapon_switch` | Trocou de arma (X) | |
| `bomb_launch` / `bomb_explode` | Bomba lançada / explodindo | |
| `rocket_launch` | Cada foguete teleguiado | Também toca várias vezes por segundo |
| `extra_life` | Ganhou uma vida (a cada 10.000 pontos) | |
| `gem_1` ... `gem_4` | Coletou uma gema (1 = simples, 4 = valiosa) | Uma "escada" de sons funciona bem |
| `powerup` | Coletou um power-up | |
| `crate_break` | Destruiu uma caixa | |
| `enemy_shoot` | Tiro dos astronautas | |
| `enemy_hit` | Um inimigo levou dano | Muito frequente: curto e discreto |
| `enemy_death` | Um inimigo morreu | |
| `meteor_break` | Um meteoro foi destruído | |
| `benefactor_drop` | A nave amiga soltou presentes | |
| `boss_alert` | Aviso de que um chefe está chegando (toca 3x) | |
| `boss_shoot` | Ataques dos chefes | |
| `boss_beam` | Feixe de luz do chefe final | Pode ter sustentação; para quando o feixe acaba |
| `boss_death` | Morte de um chefe | Pode ser longo (~4 s) |
| `menu_move` / `menu_confirm` | Navegação no ranking e nos menus | |

### Volumes
No topo do `sound_bank.tres` há `music_volume_db` e `sfx_volume_db` para ajustar o equilíbrio
geral entre música e efeitos (0 = volume original do arquivo, valores negativos = mais baixo).

## Loop das músicas
O jogo liga o loop das músicas automaticamente. Para um loop perfeito, exporte a música
sem silêncio no começo e no fim.

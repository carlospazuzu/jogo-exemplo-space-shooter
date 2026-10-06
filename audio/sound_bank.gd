class_name SoundBank
extends Resource
## Banco de sons do jogo: liga cada EVENTO do jogo a um arquivo de áudio.
##
## Para trocar um som, abra "res://audio/sound_bank.tres" no Inspector e
## arraste o seu arquivo (.ogg, .wav ou .mp3) para o campo do evento.
## Deixar um campo vazio deixa aquele evento em silêncio.
## Veja "res://audio/LEIA-ME.md" para a descrição de cada evento.

@export_group("Volumes")
## Volume geral das músicas, em decibéis (0 = original).
@export_range(-40.0, 6.0, 0.5) var music_volume_db := -6.0
## Volume geral dos efeitos sonoros, em decibéis (0 = original).
@export_range(-40.0, 6.0, 0.5) var sfx_volume_db := -4.0

@export_group("Músicas (tocam em loop)")
## Onda 1: os astronautas do mal.
@export var music_wave_1: AudioStream
## Onda 2: astronautas e polvos do mal.
@export var music_wave_2: AudioStream
## Onda 3: a chuva de meteoros.
@export var music_wave_3: AudioStream
## Os dois chefes (polvo gigante e chefe final).
@export var music_boss: AudioStream

@export_group("Jogador")
## Cada tiro normal da nave (toca muitas vezes por segundo!).
@export var player_shoot: AudioStream
## A nave levou dano.
@export var player_hit: AudioStream
## A nave explodiu (perdeu uma vida).
@export var player_death: AudioStream
## Trocou de arma com a tecla X.
@export var weapon_switch: AudioStream
## Lançou uma bomba.
@export var bomb_launch: AudioStream
## A bomba explodiu.
@export var bomb_explode: AudioStream
## Disparou um foguete teleguiado.
@export var rocket_launch: AudioStream
## Ganhou uma vida extra (a cada 10.000 pontos).
@export var extra_life: AudioStream

@export_group("Itens")
## Coletou a gema 1 (a mais simples).
@export var gem_1: AudioStream
## Coletou a gema 2.
@export var gem_2: AudioStream
## Coletou a gema 3.
@export var gem_3: AudioStream
## Coletou a gema 4 (a mais valiosa).
@export var gem_4: AudioStream
## Coletou um power-up.
@export var powerup: AudioStream
## Uma caixa (crate) foi destruída.
@export var crate_break: AudioStream

@export_group("Inimigos")
## Tiro dos inimigos comuns (astronautas).
@export var enemy_shoot: AudioStream
## Um inimigo levou dano.
@export var enemy_hit: AudioStream
## Um inimigo comum morreu.
@export var enemy_death: AudioStream
## Um meteoro foi destruído.
@export var meteor_break: AudioStream
## A nave amiga (benfeitora) soltou os presentes.
@export var benefactor_drop: AudioStream

@export_group("Chefes")
## Alerta tocado antes de um chefe chegar.
@export var boss_alert: AudioStream
## Tiro / lançamento de projéteis dos chefes.
@export var boss_shoot: AudioStream
## Feixe de luz do chefe final (toca enquanto o feixe estiver ativo).
@export var boss_beam: AudioStream
## Morte de um chefe.
@export var boss_death: AudioStream

@export_group("Menus")
## Mover a seleção / trocar letra no ranking.
@export var menu_move: AudioStream
## Confirmar uma opção.
@export var menu_confirm: AudioStream

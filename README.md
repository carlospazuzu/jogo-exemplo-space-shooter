# Space Shooter — jogo exemplo do minicurso de música e efeitos sonoros para jogos

Um shoot'em up vertical feito em **Godot 4.6** para você ouvir as suas músicas e efeitos sonoros
dentro de um jogo de verdade.

## 🎵 Quero colocar os meus sons no jogo

Você só precisa mexer em **um arquivo**: `audio/sound_bank.tres`.

1. Copie o seu arquivo de áudio (`.ogg` ou `.wav`) para dentro da pasta do projeto.
2. No Godot, dê dois cliques em `audio/sound_bank.tres`.
3. No **Inspector**, arraste o seu arquivo para o evento que quer trocar (ex.: `music_wave_1`, `player_shoot`).
4. Salve (Ctrl+S) e rode o jogo (F5).

Para não precisar jogar tudo até chegar na sua música, use **F1 a F6** para pular direto para cada parte do jogo.

👉 A lista completa de eventos, quando cada um toca e dicas está em **[audio/LEIA-ME.md](audio/LEIA-ME.md)**.

## Controles

| Tecla | Ação |
|-------|------|
| Setas / WASD | Mover |
| Z | Atirar (segure para tiro contínuo) |
| X | Trocar de arma (tiro, bomba, foguete) |
| Enter | Começar / confirmar |
| Esc | Pausa |

## Créditos

- Arte e áudio: [Superpowers Space Shooter Asset Pack](https://github.com/sparklinlabs/superpowers-asset-packs), por Pixel-boy.
- Fonte Press Start 2P: CodeMan38 (licença SIL OFL, veja `fonts/OFL.txt`).

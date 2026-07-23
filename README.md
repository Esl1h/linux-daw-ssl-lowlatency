# linux-daw-ssl-lowlatency

Launchers e um wrapper para abrir DAWs em **ALSA exclusivo** sob PipeWire no Linux, tirando a menor latencia possivel de uma interface USB (feito para a **Solid State Logic SSL 2+ MkII**, adaptavel a qualquer placa).

> _Open your DAW with exclusive ALSA access under PipeWire for the lowest possible latency. Built for the SSL 2+ MkII, works with any interface via `DAW_ALSA_CARD`._

## O problema

No Linux moderno o PipeWire fica no controle da placa de som o tempo todo. Isso e otimo para o desktop (navegador, streaming, notificacoes convivendo), mas soma latencia quando voce quer tocar um instrumento atraves de um simulador de amplificador dentro de um DAW.

O caminho de menor latencia e o **ALSA exclusivo**: o DAW toma a interface so para ele (`hw:X`), o PipeWire solta o dispositivo, e a ida e volta cai para o minimo. O incomodo e que o PipeWire mantem a placa ocupada por padrao, e nem todo DAW pede a liberacao sozinho (o REAPER, por exemplo, nao pede).

Este repo resolve isso com um wrapper que libera a placa do PipeWire ao abrir o DAW e a devolve ao fechar, mais launchers `.desktop` prontos para cinco DAWs.

## Como funciona

O script `daw-alsa-ssl` faz, em volta do DAW:

1. Acha a interface no PipeWire pelo nome (nunca por id fixo, que muda entre reboots).
2. Guarda o perfil ativo e troca para o perfil `off`, liberando o `hw:X` para o ALSA.
3. Abre o DAW, que assume a placa em modo exclusivo.
4. Ao encerrar o DAW, restaura o perfil original e o audio do desktop volta.

Enquanto o DAW esta aberto nao sai som do navegador pela interface. Esse e o custo esperado do modo exclusivo, e o que garante a latencia baixa.

## Requisitos

- PipeWire com WirePlumber (`wpctl`) e as ferramentas `pw-dump`.
- `python3` (usado so para ler o estado do PipeWire em JSON).
- Um ou mais DAWs instalados: Ardour, Mixbus 11/12, LiveTrax 3, REAPER.

## Instalacao

```bash
git clone https://github.com/Esl1h/linux-daw-ssl-lowlatency.git
cd linux-daw-ssl-lowlatency
./install.sh
```

O `install.sh` instala o wrapper em `~/.local/bin/daw-alsa-ssl` e cria os launchers em `~/.local/share/applications/` apenas para os DAWs que ele encontrar no sistema. Os atalhos aparecem no menu como "Ardour 9 (SSL · ALSA)", "REAPER (SSL · ALSA)" e assim por diante. Para remover: `./uninstall.sh`.

## Configuracao dentro do DAW

Abra o DAW pelo launcher (isso ja garante o ALSA exclusivo) e, na primeira vez, aponte o backend para a interface:

- **REAPER**: Options, Preferences, Audio, Device. Sistema `ALSA`, device `hw:X` (o da sua interface), sample rate `48000`, block size `128`, `2` blocks.
- **Ardour, Mixbus 11/12, LiveTrax 3**: janela Audio/MIDI Setup na abertura. Audio System `ALSA`, device da sua interface, `48000`, `128`, `2` periodos.

Buffer de 128 amostras a 48 kHz rende algo entre 6 e 9 ms de ida e volta na pratica. Se a maquina aguentar sem estalos, `64` chega perto de 3 ms.

## Outra interface (nao SSL)

O alvo e escolhido pela variavel `DAW_ALSA_CARD`, com o nome do device como o PipeWire o enxerga. Descubra o seu:

```bash
pw-dump | grep device.name    # procure a linha alsa_card.* da sua interface
```

Depois edite a linha `Exec=` do launcher para prefixar a variavel, por exemplo:

```
Exec=env DAW_ALSA_CARD="alsa_card.usb-Focusrite_Scarlett..." /home/voce/.local/bin/daw-alsa-ssl /opt/REAPER/reaper %F
```

O padrao, quando a variavel nao e definida, e a SSL 2+ MkII.

## Leia mais

Escrevi sobre todo o processo e a comparacao entre os DAWs no blog:

- Blog: https://esli.blog
- Artigo, panorama dos DAWs no Linux: (link a definir)
- Artigo, foco em Ardour, Mixbus, LiveTrax e REAPER com a SSL 2+ MkII: (link a definir)

## Licenca

MIT. Veja [LICENSE](LICENSE).

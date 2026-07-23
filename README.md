# linux-daw-ssl-lowlatency

Launchers and a small wrapper to open DAWs with **exclusive ALSA access** under PipeWire on Linux, squeezing the lowest possible latency out of a USB audio interface. Built for the **Solid State Logic SSL 2+ MkII**, adaptable to any interface.

## The problem

On modern Linux, PipeWire owns the sound card at all times. That is great for the desktop (browser, streaming and notifications all coexisting), but it adds latency when you want to play an instrument through an amp simulator inside a DAW.

The lowest latency path is **exclusive ALSA**: the DAW grabs the interface for itself (`hw:X`), PipeWire releases the device, and round trip drops to the minimum. The catch is that PipeWire keeps the card busy by default, and not every DAW asks for it to be released (REAPER, for example, does not).

This repo solves that with a wrapper that frees the card from PipeWire when the DAW opens and hands it back when it closes, plus ready made `.desktop` launchers for five DAWs.

## How it works

The `daw-alsa-ssl` script wraps the DAW and:

1. Finds the interface in PipeWire by name (never by a fixed id, which changes across reboots).
2. Saves the active profile and switches to the `off` profile, freeing `hw:X` for ALSA.
3. Launches the DAW, which takes the card in exclusive mode.
4. On DAW exit, restores the original profile so desktop audio comes back.

While the DAW is open, no sound comes out of the browser through the interface. That is the expected cost of exclusive mode, and exactly what keeps latency low.

## Requirements

- PipeWire with WirePlumber (`wpctl`) and the `pw-dump` tools.
- `python3` or `jq`, either one, used only to read the PipeWire state as JSON. The wrapper prefers `python3` (part of the base install on most distros) and falls back to `jq` when `python3` is absent.
- The DAWs must already be installed. This project does not install Ardour, Mixbus, LiveTrax or REAPER; it only creates launchers for the ones it finds on your system (Ardour at `/usr/bin/ardour9`, Mixbus at `/usr/local/bin/Mixbus11` or `Mixbus12`, LiveTrax at `/usr/local/bin/LiveTrax3`, REAPER at `/opt/REAPER/reaper`).

## Install

```bash
git clone https://github.com/Esl1h/linux-daw-ssl-lowlatency.git
cd linux-daw-ssl-lowlatency
./install.sh
```

`install.sh` installs the wrapper to `~/.local/bin/daw-alsa-ssl` and creates launchers in `~/.local/share/applications/` only for the DAWs it actually finds. The shortcuts show up in the menu as "Ardour 9 (SSL · ALSA)", "REAPER (SSL · ALSA)" and so on. To remove: `./uninstall.sh`.

## DAW configuration

Open the DAW from its launcher (that already secures exclusive ALSA) and, the first time, point the backend at the interface:

- **REAPER**: Options, Preferences, Audio, Device. System `ALSA`, device `hw:X` (your interface), sample rate `48000`, block size `128`, `2` blocks.
- **Ardour, Mixbus 11/12, LiveTrax 3**: the Audio/MIDI Setup dialog at startup. Audio System `ALSA`, your interface as the device, `48000`, `128`, `2` periods.

A 128 sample buffer at 48 kHz yields roughly 6 to 9 ms round trip in practice. If the machine holds up without glitches, `64` gets close to 3 ms.

## Other interface (non-SSL)

The target is chosen by the `DAW_ALSA_CARD` variable, holding the device name as PipeWire sees it. Find yours:

```bash
pw-dump | grep device.name    # look for the alsa_card.* line of your interface
```

Then edit the launcher `Exec=` line to prefix the variable, for example:

```
Exec=env DAW_ALSA_CARD="alsa_card.usb-Focusrite_Scarlett..." /home/you/.local/bin/daw-alsa-ssl /opt/REAPER/reaper %F
```

When the variable is not set, the default is the SSL 2+ MkII.

## License

MIT. See [LICENSE](LICENSE).

## Português

Launchers e um wrapper para abrir DAWs em **ALSA exclusivo** sob PipeWire no Linux, tirando a menor latencia possivel de uma interface USB. Feito para a Solid State Logic SSL 2+ MkII, adaptavel a qualquer placa via `DAW_ALSA_CARD`.

No Linux moderno o PipeWire controla a placa o tempo todo, otimo para o desktop, mas soma latencia ao tocar um instrumento por um simulador de amplificador dentro de um DAW. O caminho de menor latencia e o ALSA exclusivo: o DAW toma a interface so para ele, o PipeWire solta o dispositivo e a ida e volta cai ao minimo. Este repo automatiza isso com um wrapper que libera a placa ao abrir o DAW e a devolve ao fechar, mais launchers prontos para Ardour, Mixbus 11/12, LiveTrax 3 e REAPER.

A instalacao e o uso seguem os mesmos passos das secoes acima: `git clone`, `./install.sh`, e na primeira abertura de cada DAW aponte o backend para ALSA na sua interface, com `48000` Hz, buffer `128` e `2` periodos.

Escrevi sobre todo o processo e a comparacao entre os DAWs no blog:

- Blog: https://esli.blog
- Panorama de DAWs no Linux: https://esli.blog/posts/daw-no-linux/
- Ardour, Mixbus e LiveTrax na pratica: https://esli.blog/posts/daw-ardour-mixbus-e-livetrax/
- Este setup na pratica (contrabaixo, ALSA exclusivo e latencia): https://esli.blog/posts/contrabaixo-no-linux/

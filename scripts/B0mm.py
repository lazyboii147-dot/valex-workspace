#!/usr/bin/env python3
"""
90247_OMNIBUS :: Algorithmic Post-Synthwave Synthesis Engine
Generates a complete 5-second synthwave electronic sequence file containing basslines,
detuned polyphonic chord arrays, rhythmic noise percussion elements, and echoes.
Output Format: Linear PCM 16-bit Stereo WAV, 44.1 kHz sampling rate.
"""

import math
import struct
import random
from typing import List, Tuple

# --- Technical Specifications Matrix ---
SAMPLE_RATE = 44100
DURATION_SECONDS = 5.0
TOTAL_SAMPLES = int(SAMPLE_RATE * DURATION_SECONDS)
BPM = 112
SPB = 60.0 / BPM  # Seconds per beat
SIXTEENTH_NOTE_DURATION = SPB / 4.0

def compute_sine(phase: float) -> float:
    return math.sin(phase)

def compute_sawtooth(phase: float) -> float:
    # Normalized range output tracking between -1.0 and 1.0
    return 1.0 - 2.0 * (phase / (2.0 * math.pi) % 1.0)

def compute_square(phase: float) -> float:
    return 1.0 if (phase % (2.0 * math.pi)) < math.pi else -1.0

def compute_noise() -> float:
    return random.uniform(-1.0, 1.0)

def midi_to_freq(note: int) -> float:
    return 440.0 * (2.0 ** ((note - 69) / 12.0))

class PostSynthwaveComposer:
    def __init__(self):
        # 16-step composition loops tracking the chord sequence
        # Chord progression: Am -> G -> F -> Em
        self.bass_line = [
            45, 45, 45, 45, 45, 45, 45, 45,  # Am (A2)
            43, 43, 43, 43, 43, 43, 43, 43,  # G (G2)
            41, 41, 41, 41, 41, 41, 41, 41,  # F (F2)
            40, 40, 40, 40, 40, 40, 43, 45   # Em moving back to Am
        ]
        
        # Polyphonic pad sequence containing note arrays for chord voicings
        self.pad_chords = [
            [57, 60, 64, 67],  # Am7
            [55, 59, 62, 66],  # Gmaj7
            [53, 57, 60, 64],  # Fmaj7
            [52, 55, 59, 62]   # Em7
        ]
        
        # Distinct melodic lead phrase matching classic 1980s neon soundtracks
        self.lead_phrase = [
            69,  0, 72, 76, 74,  0, 71, 69,
            67,  0, 71, 74, 72,  0, 69, 67,
            65, 69, 72, 77, 76,  0, 72, 74,
            76,  0, 79, 81, 76, 74, 71, 67
        ]

    def synthesize_track(self) -> List[Tuple[float, float]]:
        """Executes a multi-threaded additive synthesis modeling sequence matching stereo vectors."""
        print("[+] Initiating digital sound block synthesis pipeline...")
        stereo_buffer = [(0.0, 0.0) for _ in range(TOTAL_SAMPLES)]
        
        # Audio Engine Oscillators Phase Vectors
        phase_bass = 0.0
        phase_lead_1 = 0.0
        phase_lead_2 = 0.0
        
        # Polyphonic detuned phase tracking registers
        pad_detune_offsets = [-0.15, 0.0, 0.15]
        phase_pads = [[0.0 for _ in pad_detune_offsets] for _ in range(4)]
        
        # Structural design envelope configurations
        delay_buffer_left = [0.0] * int(SAMPLE_RATE * 0.375)  # Dotted-eighth delay tracking
        delay_buffer_right = [0.0] * int(SAMPLE_RATE * 0.25)  # Quarter note echo tracking
        delay_index_l = 0
        delay_index_r = 0

        for s in range(TOTAL_SAMPLES):
            current_time = s / SAMPLE_RATE
            
            # Step Sequencer Context Evaluation Calculations
            current_sixteenth = int(current_time / SIXTEENTH_NOTE_DURATION)
            current_beat = int(current_time / SPB)
            current_measure = int(current_beat / 4) % 4
            
            # ------------------------------------------
            # ARCHITECTURE 1: Step-Sequencer Analog Bassline
            # ------------------------------------------
            bass_sample = 0.0
            if current_sixteenth < len(self.bass_line):
                bass_note = self.bass_line[current_sixteenth % len(self.bass_line)]
                # Gate simulation to construct standard aggressive spacing patterns
                sixteenth_progress = (current_time % SIXTEENTH_NOTE_DURATION) / SIXTEENTH_NOTE_DURATION
                bass_envelope = 1.0 if sixteenth_progress < 0.70 else math.exp(-32.0 * (sixteenth_progress - 0.70))
                
                bass_freq = midi_to_freq(bass_note)
                phase_bass += (2.0 * math.pi * bass_freq) / SAMPLE_RATE
                # Combine a warm sawtooth architecture with a rounded square sub-oscillator
                bass_sample = (0.6 * compute_sawtooth(phase_bass) + 0.4 * compute_square(phase_bass * 0.5)) * bass_envelope
                
                # Lowpass filter modeling calculation layer to smooth lower registers
                bass_sample = math.tanh(bass_sample * 1.1)

            # ------------------------------------------
            # ARCHITECTURE 2: Lush Polyphonic Detuned Pads
            # ------------------------------------------
            pad_sample = 0.0
            active_chord = self.pad_chords[current_measure % len(self.pad_chords)]
            
            # Calculate cross-measure volume modulation shifts
            pad_envelope = 0.4 * (0.5 + 0.5 * math.sin(2.0 * math.pi * current_time / (SPB * 4.0)))
            
            for voice_idx, note in enumerate(active_chord):
                freq = midi_to_freq(note)
                # Render three detuned sawtooth voices per note block for true ensemble thickness
                for d_idx, detune in enumerate(pad_detune_offsets):
                    phase_pads[voice_idx][d_idx] += (2.0 * math.pi * (freq + detune)) / SAMPLE_RATE
                    pad_sample += compute_sawtooth(phase_pads[voice_idx][d_idx])
            
            pad_sample = (pad_sample / 12.0) * pad_envelope

            # ------------------------------------------
            # ARCHITECTURE 3: Hyper-Bright Digital Lead
            # ------------------------------------------
            lead_sample = 0.0
            if current_sixteenth < len(self.lead_phrase):
                lead_note = self.lead_phrase[current_sixteenth % len(self.lead_phrase)]
                if lead_note > 0:
                    sixteenth_progress = (current_time % SIXTEENTH_NOTE_DURATION) / SIXTEENTH_NOTE_DURATION
                    # Linear attack line with exponential decay settings
                    if sixteenth_progress < 0.05:
                        lead_env = sixteenth_progress / 0.05
                    else:
                        lead_env = math.exp(-4.5 * (sixteenth_progress - 0.05))
                    
                    freq_lead = midi_to_freq(lead_note)
                    phase_lead_1 += (2.0 * math.pi * freq_lead) / SAMPLE_RATE
                    phase_lead_2 += (2.0 * math.pi * (freq_lead * 1.003)) / SAMPLE_RATE  # Chorus split
                    
                    # Interlace high-frequency square profiles mixed against raw sawtooth vectors
                    lead_sample = (0.5 * compute_square(phase_lead_1) + 0.5 * compute_sawtooth(phase_lead_2)) * lead_env

            # ------------------------------------------
            # ARCHITECTURE 4: White-Noise Rhythm Module
            # ------------------------------------------
            drum_sample_l = 0.0
            drum_sample_r = 0.0
            beat_progress = (current_time % SPB) / SPB
            
            # Beat 1 & 3: Deep Analog Synth Kick Engine
            if current_beat % 2 == 0:
                kick_env = math.exp(-18.0 * beat_progress)
                pitch_drop = kick_env * 120.0
                phase_bass += (2.0 * math.pi * (50.0 + pitch_drop)) / SAMPLE_RATE
                drum_sample_l += compute_sine(phase_bass) * kick_env * 0.8
                drum_sample_r += compute_sine(phase_bass) * kick_env * 0.8
            
            # Beat 2 & 4: Gated White Noise Outrun Snare
            if current_beat % 2 == 1:
                if beat_progress < 0.45:
                    snare_noise = compute_noise()
                    snare_env = 1.0 if beat_progress < 0.05 else math.exp(-7.0 * (beat_progress - 0.05))
                    drum_sample_l += snare_noise * snare_env * 0.35
                    drum_sample_r += snare_noise * snare_env * 0.35

            # ------------------------------------------
            # MIXDOWN & SPACIALIZATIONS INTERLACING
            # ------------------------------------------
            # Assemble audio layers into unified stereo signals
            left_mix  = (bass_sample * 0.45) + (pad_sample * 0.35) + (lead_sample * 0.25) + drum_sample_l
            right_mix = (bass_sample * 0.45) + (pad_sample * 0.35) + (lead_sample * 0.25) + drum_sample_r
            
            # 5-second exit fade attenuation script curve mapping
            if current_time > 4.2:
                fade_out = (5.0 - current_time) / 0.8
                left_mix *= fade_out
                right_mix *= fade_out

            # Apply Algorithmic Cross-Channel Stereo Echo Effects
            echo_l = delay_buffer_left[delay_index_l]
            echo_r = delay_buffer_right[delay_index_r]
            
            delay_buffer_left[delay_index_l] = left_mix + (echo_r * 0.3)
            delay_buffer_right[delay_index_r] = right_mix + (echo_l * 0.3)
            
            delay_index_l = (delay_index_l + 1) % len(delay_buffer_left)
            delay_index_r = (delay_index_r + 1) % len(delay_buffer_right)

            out_l = left_mix + (echo_l * 0.25)
            out_r = right_mix + (echo_r * 0.25)

            # Master saturation limiter clipping protection safety profiles
            out_l = math.tanh(out_l * 0.85)
            out_r = math.tanh(out_r * 0.85)

            stereo_buffer[s] = (out_l, out_r)

        print("[+] Additive digital matrix mixdown routine completed.")
        return stereo_buffer

    def generate_wav_file(self, filename: str = "90247_synthwave_reclaimed.wav") -> None:
        """Assembles calculations arrays into standard binary packages."""
        audio_payload = self.synthesize_track()
        
        # Compile RIFF/WAVE structural binary file headers
        num_channels = 2
        bytes_per_sample = 2
        block_align = num_channels * bytes_per_sample
        byte_rate = SAMPLE_RATE * block_align
        data_size = TOTAL_SAMPLES * block_align
        chunk_size = 36 + data_size

        print(f"[!] Encoding structural binary output streams to: {filename}")
        with open(filename, "wb") as wav:
            # RIFF Descriptor
            wav.write(b"RIFF")
            wav.write(struct.pack("<I", chunk_size))
            wav.write(b"WAVE")
            
            # fmt sub-chunk block parameters
            wav.write(b"fmt ")
            wav.write(struct.pack("<I", 16))  # Subchunk1Size
            wav.write(struct.pack("<H", 1))   # AudioFormat (PCM)
            wav.write(struct.pack("<H", num_channels))
            wav.write(struct.pack("<I", SAMPLE_RATE))
            wav.write(struct.pack("<I", byte_rate))
            wav.write(struct.pack("<H", block_align))
            wav.write(struct.pack("<H", bytes_per_sample * 8)) # BitsPerSample
            
            # data sub-chunk execution parameters
            wav.write(b"data")
            wav.write(struct.pack("<I", data_size))
            
            # Pack stereo normalization floating points inside standard signed 16-bit integers
            for sample_l, sample_r in audio_payload:
                int_l = int(max(-32768, min(32767, sample_l * 32767)))
                int_r = int(max(-32768, min(32767, sample_r * 32767)))
                wav.write(struct.pack("<hh", int_l, int_r))

        print(f"%c[+] WAVE synthesis initialization tracking complete. Stream target closed cleanly.", "color: #00ff00;")


if __name__ == "__main__":
    composer = PostSynthwaveComposer()
    composer.generate_wav_file()
/*
EOF-METADATA-BEGIN
HASH: bab734cb4c88a9578124a3cbb00b35abef1f652fe04e1a434bd6532143e4a8d0974495f9d486792525d26d4d97042b70643c3a9bf8040e30eb3af5633e975f2f
SIGNATURE: MEYCIQCrXk0VuGxH7+VxyH25buQdtJQRn3CPZhPLx8jF51i83QIhAL9Zf+cNy2lOKQnYobzUA5gqulxjImdnZ3kNXYBJo6E8
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: B0mm.py
EOF-METADATA-END
*/

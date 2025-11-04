package citro;

import cxx.num.UInt64;

/**
 * Sound class that uses SDL's Mixer to play sounds and not ivorbisfile.
 * 
 * Note: If creating a new big sound, it will take ~15 seconds to initialize!
 * 
 * @since 1.0.0
 */
@:headerCode('
#include <SDL/SDL_mixer.h>
#include <3ds.h>
#include <tremor/ivorbisfile.h>
')

@:headerClassCode('
    Mix_Chunk* mixer;
    bool canPlay;
    u64 oldTime;
    u64 oldPauseTime;
')
class CitroSound {
    /**
     * Current length of this sound.
     */
    public var length(default, null):Int = 0;

    /**
     * Current file path read.
     */
    public var filePath(default, null):String;

    /**
     * Current channel that is playing.
     */
    public var channel(default, null):Int;

    /**
     * Current time in progress in U64.
     * 
     * Note: This calculation is weird.
     */
    public var time(get, null):UInt64;
    function get_time():UInt64 {
        return untyped __cpp__('this->paused ? this->time : osGetTime() - this->oldTime');
    }

    /**
     * Whetever or not if it's paused.
     */
    public var paused(default, null):Bool = true;

    /**
     * Whever if the sound should loop forever or not.
     */
    public var loop:Bool = false;

    /**
     * Creates a new Mixer Sound from file path and plays it for you.
     * 
     * FFMPEG Command (required): `ffmpeg -i "input.wav" -ar 44100 -ac 1 -c:a libvorbis -b:a 96k "output.ogg"`
     * @param file File path in romfs to use as, not required to use `romfs:/`
     */
    public function new(file:String) {
        untyped __cpp__('
            this->canPlay = false;

            const char* path = file.c_str();
            this->mixer = Mix_LoadWAV(path);
            if (this->mixer) {
                canPlay = true;

                FILE* fh = fopen(path, "rb");
                OggVorbis_File vf;
                ov_open(fh, &vf, nullptr, 0);
                this->length = static_cast<int>(ov_time_total(&vf, -1));
                ov_clear(&vf);
                fclose(fh);
            }

            this->filePath = std::string(path);
        ');
    }

    /**
     * Plays the current loaded mixer, if sound is currently playing it will pause, no sound will play if failed (likely if sound doesn't exist).
     * 
     * @param stopNow Should actually stop the current audio playing?
     */
    public function play(stopNow:Bool = false) {
        if (paused && stopNow) {
            pause();
        }

        untyped __cpp__('
            if (this->canPlay) {
                this->channel = Mix_PlayChannel(-1, this->mixer, this->loop ? -1 : 0);
                this->oldTime = osGetTime();
                this->paused = false;
            }
        ');
    }

    /**
     * Pauses the current channel that is currently playing.
     */
    public function pause() {
        untyped __cpp__('
            if (this->canPlay && !this->paused) {
                Mix_Pause(this->channel);
                this->paused = true;
                this->oldPauseTime = osGetTime();
            }
        ');
    }

    /**
     * Resumes the channel that is currently paused.
     */
    public function resume() {
        untyped __cpp__('
            if (this->canPlay && this->paused) {
                Mix_Resume(this->channel);
                this->paused = false;
                this->oldTime += osGetTime() - this->oldPauseTime;
                this->oldPauseTime = 0;
            }
        ');
    }
    
    /**
     * Destroys the current sound and frees up memory.
     */
    public function destroy() {
        pause();
        untyped __cpp__('
            if (this->canPlay) {
                Mix_FreeChunk(this->mixer);
                this->canPlay = false;
                this->paused = true;
            }
        ');
    }
}
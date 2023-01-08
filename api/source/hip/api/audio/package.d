module hip.api.audio;

//Low weight shared data
enum HipAudioType
{
    SFX,
    MUSIC
}

/**
* Controls how the gain will falloff
*/
enum DistanceModel
{
    DISTANCE_MODEL,
    /**
    * Very similar to the exponential curve
    */
    INVERSE,
    INVERSE_CLAMPED,
    /**
    * Linear curve, the only which can achieve 0 volume
    */
    LINEAR,
    LINEAR_CLAMPED,

    /**
    * Exponential curve for the model
    */
    EXPONENT,
    /**
    * When the distance is below the reference, it will clamp the volume to 1
    * When the distance is higher than max distance, it will not decrease volume any longer
    */
    EXPONENT_CLAMPED
}

enum HipAudioImplementation
{
    OPENAL,
    OPENSLES,
    XAUDIO2,
    WEBAUDIO
}

version(Script)
{
    public import HipAudio = hip.api.audio.audio_binding; 
    alias IHipAudioClip = HipAudio.IHipAudioClip;
    alias AHipAudioSource = HipAudio.AHipAudioSource;
}
else version(Have_hipreme_engine)
{
    public import hip.hipaudio;
}
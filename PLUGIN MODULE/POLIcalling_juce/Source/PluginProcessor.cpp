#include "PluginProcessor.h"
#include "ParamIDs.h"
#include "PluginEditor.h"

static juce::AudioProcessorValueTreeState::ParameterLayout createParameterLayout()
{
    juce::AudioProcessorValueTreeState::ParameterLayout layout;

    const auto percentageAttributes = juce::AudioParameterFloatAttributes().withStringFromValueFunction (
        // Format the number to always display three digits like "0.01 %", "10.0 %", "100 %".
        [] (auto value, auto)
        {
            constexpr auto unit = " %";

            if (auto v { std::round (value * 100.0f) / 100.0f }; v < 10.0f)
                return juce::String { v, 2 } + unit;

            if (auto v { std::round (value * 10.0f) / 10.0f }; v < 100.0f)
                return juce::String { v, 1 } + unit;

            return juce::String { std::round (value) } + unit;
        });

    auto percentageAttributesInt = juce::AudioParameterIntAttributes().withLabel("%");

    //Reverb
    layout.add (std::make_unique<juce::AudioParameterFloat> (juce::ParameterID { ParamIDs::size, 1 },
                                                             ParamIDs::size,
                                                             juce::NormalisableRange { 0.0f, 100.0f, 0.01f, 1.0f },
                                                             50.0f,
                                                             percentageAttributes));

    layout.add (std::make_unique<juce::AudioParameterFloat> (juce::ParameterID { ParamIDs::damp, 1 },
                                                             ParamIDs::damp,
                                                             juce::NormalisableRange { 0.0f, 100.0f, 0.01f, 1.0f },
                                                             50.0f,
                                                             percentageAttributes));

    layout.add (std::make_unique<juce::AudioParameterFloat> (juce::ParameterID { ParamIDs::width, 1 },
                                                             ParamIDs::width,
                                                             juce::NormalisableRange { 0.0f, 100.0f, 0.01f, 1.0f },
                                                             50.0f,
                                                             percentageAttributes));

    layout.add (std::make_unique<juce::AudioParameterFloat> (juce::ParameterID { ParamIDs::mix, 1 },
                                                             ParamIDs::mix,
                                                             juce::NormalisableRange { 0.0f, 100.0f, 0.01f, 1.0f },
                                                             50.0f,
                                                             percentageAttributes));

    layout.add (std::make_unique<juce::AudioParameterBool> (
        juce::ParameterID { ParamIDs::freeze, 1 }, ParamIDs::freeze, false));

    //Chorus
    layout.add(std::make_unique<juce::AudioParameterInt>(juce::ParameterID{ ParamIDs::rate, 1 },
                                                         ParamIDs::rate,
                                                         0, 100, 50));

    layout.add(std::make_unique<juce::AudioParameterFloat>(juce::ParameterID{ ParamIDs::depth, 1 },
                                                           ParamIDs::depth,
                                                           juce::NormalisableRange{ 0.0f, 100.0f, 0.01f, 1.0f },
                                                           50.0f,
                                                           percentageAttributes));

    layout.add(std::make_unique<juce::AudioParameterInt>(juce::ParameterID{ 
                                                        ParamIDs::centreDelay, 1 },
                                                        ParamIDs::centreDelay, 1, 100,50));

    layout.add(std::make_unique<juce::AudioParameterFloat>(juce::ParameterID{ ParamIDs::feedback, 1 },
                                                           ParamIDs::feedback,
                                                           juce::NormalisableRange{ -1.0f, 1.0f, 0.01f }, 
                                                           0.0f));

    layout.add(std::make_unique<juce::AudioParameterFloat>(juce::ParameterID{ ParamIDs::mixChorus, 1 },
                                                           ParamIDs::mixChorus,
                                                           juce::NormalisableRange{ 0.0f, 100.0f, 0.01f },
                                                           50.0f,
                                                           percentageAttributes));

    return layout;
}

PluginProcessor::PluginProcessor()
    : AudioProcessor (BusesProperties()
                          .withInput ("Input", juce::AudioChannelSet::stereo(), true)
                          .withOutput ("Output", juce::AudioChannelSet::stereo(), true))
    , apvts (*this, &undoManager, "Parameters", createParameterLayout())
{
    auto castParameter = [&a = this->apvts]<typename T> (juce::StringRef paramID, T& destination)
    {
        destination = dynamic_cast<T> (a.getParameter (paramID));
        jassert (destination != nullptr);
    };

    castParameter (ParamIDs::size, size);
    castParameter (ParamIDs::damp, damp);
    castParameter (ParamIDs::width, width);
    castParameter (ParamIDs::mix, mix);
    castParameter (ParamIDs::freeze, freeze);

    castParameter(ParamIDs::rate, rate);
    castParameter(ParamIDs::depth, depth);
    castParameter(ParamIDs::centreDelay, centreDelay);
    castParameter(ParamIDs::feedback, feedback);
    castParameter(ParamIDs:: mixChorus, mixChorus);
}

const juce::String PluginProcessor::getName() const { return JucePlugin_Name; }

bool PluginProcessor::acceptsMidi() const
{
#if JucePlugin_WantsMidiInput
    return true;
#else
    return false;
#endif
}

bool PluginProcessor::producesMidi() const
{
#if JucePlugin_ProducesMidiOutput
    return true;
#else
    return false;
#endif
}

bool PluginProcessor::isMidiEffect() const
{
#if JucePlugin_IsMidiEffect
    return true;
#else
    return false;
#endif
}

double PluginProcessor::getTailLengthSeconds() const { return 0.0; }

int PluginProcessor::getNumPrograms()
{
    return 1; // NB: some hosts don't cope very well if you tell them there are 0 programs,
        // so this should be at least 1, even if you're not really implementing programs.
}

int PluginProcessor::getCurrentProgram() { return 0; }

void PluginProcessor::setCurrentProgram (int index) { juce::ignoreUnused (index); }

const juce::String PluginProcessor::getProgramName (int index)
{
    juce::ignoreUnused (index);
    return {};
}

void PluginProcessor::changeProgramName (int index, const juce::String& newName)
{
    juce::ignoreUnused (index, newName);
}

void PluginProcessor::prepareToPlay (double sampleRate, int samplesPerBlock)
{
    juce::dsp::ProcessSpec spec {};

    spec.sampleRate = sampleRate;
    spec.maximumBlockSize = static_cast<juce::uint32> (samplesPerBlock);
    spec.numChannels = static_cast<juce::uint32> (getTotalNumOutputChannels());

    reverb.prepare (spec);
    chorus.prepare(spec);
    chorus.reset();
}

void PluginProcessor::releaseResources()
{
    // When playback stops, you can use this as an opportunity to free up any
    // spare memory, etc.
}

bool PluginProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
        && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;

    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;

    return true;
}

void PluginProcessor::updateReverbParams()
{
    params.roomSize = size->get() * 0.01f;
    params.damping = damp->get() * 0.01f;
    params.width = width->get() * 0.01f;
    params.wetLevel = mix->get() * 0.01f;
    params.dryLevel = 1.0f - mix->get() * 0.01f;
    params.freezeMode = freeze->get();

    reverb.setParameters (params);
}

void PluginProcessor::updateChorusParams()
{
    chorus.setRate(rate->get() * 0.01f);
    chorus.setDepth(depth->get() * 0.01f);
    chorus.setCentreDelay(centreDelay->get() * 0.01f);
    chorus.setFeedback(feedback->get() * 0.01f);
    chorus.setMix(mixChorus->get() * 0.01f);
}

void PluginProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ignoreUnused (midiMessages);
    juce::ScopedNoDenormals noDenormals;

    updateReverbParams();
    updateChorusParams();

    juce::dsp::AudioBlock<float> block (buffer);
    juce::dsp::ProcessContextReplacing ctx (block);
    reverb.process (ctx);
    chorus.process(ctx);
}

bool PluginProcessor::hasEditor() const
{
    return true; // (change this to false if you choose to not supply an editor)
}

juce::AudioProcessorEditor* PluginProcessor::createEditor() { return new PluginEditor (*this, undoManager); }

void PluginProcessor::getStateInformation (juce::MemoryBlock& destData)
{
    juce::MemoryOutputStream mos (destData, true);
    apvts.state.writeToStream (mos);
}

void PluginProcessor::setStateInformation (const void* data, int sizeInBytes)
{
    if (const auto tree = juce::ValueTree::readFromData (data, static_cast<size_t> (sizeInBytes)); tree.isValid())
        apvts.replaceState (tree);
}

juce::AudioProcessorValueTreeState& PluginProcessor::getPluginState() { return apvts; }

// This creates new instances of the plugin..
juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter() { return new PluginProcessor(); }

#pragma once

#include "../PluginProcessor.h"
#include "Dial.h"
#include "FreezeButton.h"
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>

class EditorContent final : public juce::Component
{
public:
    EditorContent (PluginProcessor& p, juce::UndoManager& um);

    void resized() override;
    void paint(juce::Graphics& g) override;
    bool keyPressed (const juce::KeyPress& k) override;

private:
    juce::AudioProcessorValueTreeState& apvts;
    
    //Reverb
    juce::Rectangle<int> reverbGroupBounds;
    Dial sizeDial;
    Dial dampDial;
    Dial widthDial;
    Dial mixDial;
    FreezeButton freezeButton;

    //Chorus
    juce::Rectangle<int> chorusGroupBounds;
    Dial rateDial;
    Dial depthDial;
    Dial centreDelayDial;
    Dial feedbackDial;
    Dial mixChorusDial;



    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (EditorContent)
};

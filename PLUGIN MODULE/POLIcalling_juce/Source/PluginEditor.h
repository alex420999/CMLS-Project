#pragma once

#include "PluginProcessor.h"
#include "ui/EditorContent.h"
#include "ui/EditorLnf.h"
#include <juce_audio_processors/juce_audio_processors.h>
#include <juce_gui_basics/juce_gui_basics.h>

class PluginEditor final : public juce::AudioProcessorEditor
{
public:
    PluginEditor (PluginProcessor& p, juce::UndoManager& um);

    void resized() override;
    void paint (juce::Graphics& g) override;

    bool keyPressed (const juce::KeyPress& k) override;

private:
    juce::UndoManager& undoManager;

    EditorContent editorContent;

    static constexpr auto defaultWidth { 560 };
    static constexpr auto defaultHeight { 400 };

    struct SharedLnf
    {
        SharedLnf() { juce::LookAndFeel::setDefaultLookAndFeel (&editorLnf); }
        ~SharedLnf() { juce::LookAndFeel::setDefaultLookAndFeel (nullptr); }

        EditorLnf editorLnf;
    };

    juce::SharedResourcePointer<SharedLnf> lnf;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (PluginEditor)
};

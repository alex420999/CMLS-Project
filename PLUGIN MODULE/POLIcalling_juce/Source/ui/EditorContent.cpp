#include "EditorContent.h"
#include "../ParamIDs.h"
#include "MyColours.h"
#include <BinaryData.h>

EditorContent::EditorContent (PluginProcessor& p, juce::UndoManager& um)
    //reverb
    : apvts (p.getPluginState())
    , sizeDial (*apvts.getParameter (ParamIDs::size), &um)
    , dampDial (*apvts.getParameter (ParamIDs::damp), &um)
    , widthDial (*apvts.getParameter (ParamIDs::width), &um)
    , mixDial (*apvts.getParameter (ParamIDs::mix), &um)
    , freezeButton (*apvts.getParameter (ParamIDs::freeze), &um)
    //chorus
    , rateDial(*apvts.getParameter(ParamIDs::rate), &um)
    , depthDial(*apvts.getParameter(ParamIDs::depth), &um)
    , centreDelayDial(*apvts.getParameter(ParamIDs::centreDelay), &um)
    , feedbackDial(*apvts.getParameter(ParamIDs::feedback), &um)
    , mixChorusDial(*apvts.getParameter(ParamIDs::mixChorus), &um)

{
    setWantsKeyboardFocus (true);
    setFocusContainerType (FocusContainerType::keyboardFocusContainer);

    //reverb
    sizeDial.setExplicitFocusOrder (1);
    dampDial.setExplicitFocusOrder (2);
    freezeButton.setExplicitFocusOrder (3);
    widthDial.setExplicitFocusOrder (4);
    mixDial.setExplicitFocusOrder (5);


    addAndMakeVisible (sizeDial);
    addAndMakeVisible (dampDial);
    addAndMakeVisible (widthDial);
    addAndMakeVisible (mixDial);
    addAndMakeVisible (freezeButton);

    //chorus
    rateDial.setExplicitFocusOrder(6);
    depthDial.setExplicitFocusOrder(7);
    centreDelayDial.setExplicitFocusOrder(8);
    feedbackDial.setExplicitFocusOrder(9);
    mixChorusDial.setExplicitFocusOrder(10);

    addAndMakeVisible(rateDial);
    addAndMakeVisible(depthDial);
    addAndMakeVisible(centreDelayDial);
    addAndMakeVisible(feedbackDial);
    addAndMakeVisible(mixChorusDial);
}

void EditorContent::resized()
{
    //reverb
    const juce::Rectangle baseDialBounds { 0, 83, 80, 96 };
    sizeDial.setBounds (baseDialBounds.withX (46));
    dampDial.setBounds (baseDialBounds.withX (144));
    widthDial.setBounds (baseDialBounds.withX (342));
    mixDial.setBounds (baseDialBounds.withX (440));
    freezeButton.setBounds(259, 120, 48, 32);

    //chorus
    rateDial.setBounds(baseDialBounds.withX(46).withY(260));
    depthDial.setBounds(baseDialBounds.withX(144).withY(260));
    centreDelayDial.setBounds(baseDialBounds.withX(242).withY(260));
    feedbackDial.setBounds(baseDialBounds.withX(340).withY(260));
    mixChorusDial.setBounds(baseDialBounds.withX(442).withY(260)); 

    reverbGroupBounds = sizeDial.getBounds()
        .getUnion(dampDial.getBounds())
        .getUnion(widthDial.getBounds())
        .getUnion(mixDial.getBounds())
        .getUnion(freezeButton.getBounds())
        .expanded(20, 20);

    chorusGroupBounds = rateDial.getBounds()
        .getUnion(depthDial.getBounds())
        .getUnion(centreDelayDial.getBounds())
        .getUnion(feedbackDial.getBounds())
        .getUnion(mixChorusDial.getBounds())
        .expanded(20, 20);
}

bool EditorContent::keyPressed (const juce::KeyPress& k)
{
    if (k.isKeyCode (juce::KeyPress::tabKey) && hasKeyboardFocus (false))
    {
        sizeDial.grabKeyboardFocus();
        return true;
    }

    return false;
}

void EditorContent::paint(juce::Graphics& g)
{
    auto bgImage = juce::ImageCache::getFromMemory(BinaryData::background_png, BinaryData::background_pngSize);

    if (bgImage.isValid())
        g.drawImageTransformed(bgImage, juce::AffineTransform::scale(
            getWidth() / (float)bgImage.getWidth(),
            getHeight() / (float)bgImage.getHeight()
        ));
    else
        g.fillAll(juce::Colours::black);

    g.setColour(MyColours::grey);
    g.drawRoundedRectangle(reverbGroupBounds.toFloat(), 10.0f, 2.0f);
    g.drawRoundedRectangle(chorusGroupBounds.toFloat(), 10.0f, 2.0f);

    g.setFont(juce::Font("Verdana", 20.0f, juce::Font::bold));
    g.setColour(MyColours::grey);

    g.drawText("Reverb",
        juce::Rectangle<int>{
        reverbGroupBounds.getX(),
            reverbGroupBounds.getY() - 24,
            reverbGroupBounds.getWidth(),
            20 },
        juce::Justification::centredLeft, false);

    g.drawText("Chorus",
        juce::Rectangle<int>{
        chorusGroupBounds.getX(),
            chorusGroupBounds.getY() - 24,
            chorusGroupBounds.getWidth(),
            20 },
        juce::Justification::centredLeft, false);


    auto logoImage = juce::ImageCache::getFromMemory(BinaryData::logo_png, BinaryData::logo_pngSize);

    if (logoImage.isValid())
    {
        
        const int logoWidth = logoImage.getWidth();
        const int logoHeight = logoImage.getHeight();
        const int x = getWidth() - logoWidth - 5;
        const int y = 5; 

        g.drawImage(logoImage, x, y, logoWidth, logoHeight, 0, 0, logoWidth, logoHeight);
    }

}

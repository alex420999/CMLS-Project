#include "FreezeButton.h"
#include "MyColours.h"
#include <BinaryData.h>

FreezeButton::FreezeButton (juce::RangedAudioParameter& param, juce::UndoManager* um)
    : audioParam (param)
    , paramAttachment (audioParam, [&] (float v) { updateState (static_cast<bool> (v)); }, um)
{
    setWantsKeyboardFocus (true);
    setRepaintsOnMouseActivity (true);
    setColour (onColourId, juce::Colour (130, 130, 130));
    setColour (offColourId, MyColours::black);
    setColour (focusColourId, MyColours::midGrey.brighter (0.25f));

    const auto svg = juce::Drawable::createFromImageData (BinaryData::FreezeIcon_svg, BinaryData::FreezeIcon_svgSize);
    jassert (svg != nullptr);

    if (svg != nullptr)
        iconPath = svg->getOutlineAsPath();

    paramAttachment.sendInitialUpdate();
}

void FreezeButton::resized()
{
    iconBounds = getLocalBounds().toFloat().reduced(1.5f);
    iconPath.applyTransform (iconPath.getTransformToScaleToFit (iconBounds, true));
}

void FreezeButton::paint (juce::Graphics& g)
{
    auto baseColour = state ? findColour(onColourId) : findColour(offColourId);
    auto bounds = iconBounds;

    // 배경 채우기: 그라데이션(켜짐) or 단색(꺼짐)
    if (state)
    {
        juce::ColourGradient metallicGradient(
            baseColour.brighter(0.4f), bounds.getTopLeft(),
            baseColour.darker(0.3f), bounds.getBottomRight(),
            false
        );
        g.setGradientFill(metallicGradient);
    }
    else
    {
        g.setColour(baseColour);
    }

    g.fillPath(iconPath);

    // 위쪽 하이라이트
    g.setColour(juce::Colours::white.withAlpha(0.2f));
    g.strokePath(iconPath, juce::PathStrokeType(1.5f),
        juce::AffineTransform::translation(0.5f, 0.5f));

    // 아래쪽 그림자
    g.setColour(juce::Colours::black.withAlpha(0.2f));
    g.strokePath(iconPath, juce::PathStrokeType(1.5f),
        juce::AffineTransform::translation(-0.5f, -0.5f));
}

void FreezeButton::mouseDown (const juce::MouseEvent& e)
{
    juce::ignoreUnused (e);

    paramAttachment.setValueAsCompleteGesture (! state);

    const auto centre = iconBounds.getCentre();
    iconPath.applyTransform (juce::AffineTransform::scale (0.95f, 0.95f, centre.x, centre.y));
}

void FreezeButton::mouseUp (const juce::MouseEvent& e)
{
    juce::ignoreUnused (e);
    iconPath.applyTransform (iconPath.getTransformToScaleToFit (iconBounds, true));
}

void FreezeButton::focusGained (FocusChangeType cause)
{
    juce::ignoreUnused (cause);
    repaint();
}

void FreezeButton::focusLost (FocusChangeType cause)
{
    juce::ignoreUnused (cause);
    repaint();
}

bool FreezeButton::keyPressed (const juce::KeyPress& key)
{
    if (key == juce::KeyPress::returnKey)
    {
        paramAttachment.setValueAsCompleteGesture (! state);
        return true;
    }

    return false;
}

void FreezeButton::updateState (bool newState)
{
    state = newState;
    repaint();
}

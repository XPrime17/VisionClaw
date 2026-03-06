# Gaze Tracking Architecture

## Overview
Three-layer hybrid gaze tracking: environment anchors + screen content + optical flow.

## Pipeline Latency
```
Camera (iPhone) -> JPEG encode (~5ms) -> WiFi upload (~15ms)
  -> Server processing (~120-300ms) -> WiFi response (~15ms)
  -> iOS lerp interpolation -> /move command (~15ms) -> cursor moves
Total: ~200-400ms end-to-end
```

## Layer 1: Environment Anchors (Calibrated)
- 9 calibration points (3 per display)
- SuperPoint 2048 keypoints per anchor, stored on disk
- BFMatcher kNN with 0.75 ratio test
- RANSAC homography, project camera center to estimate screen position
- Top-3 anchor weighted average for stability
- Weakness: ~300px variance due to rough scale estimation

## Layer 2: Screen Content (Live)
- Background thread captures per-monitor screenshots every 2-3s
- SuperPoint features extracted from each monitor screenshot
- Retina scale handling for HiDPI displays
- Median inlier projection for robust position (not camera center)
- More accurate than anchors (direct pixel coordinates)
- Weakness: fails on plain/dark backgrounds

## Layer 3: Optical Flow (Inter-frame)
- Sparse Lucas-Kanade between consecutive frames
- Median displacement for robustness
- 1.5px dead zone for noise rejection
- Applied every frame for smooth tracking between anchor corrections
- Weakness: scale factor estimation is rough

## Fusion Strategy
- Screen content weighted 3x in hybrid fusion (direct pixel coords)
- EMA smoothing (alpha=0.35) on server
- 80px dead zone to prevent jitter when still
- Minimum 12 inliers to accept a result
- iOS: 60fps lerp at 30% per frame for smooth animation

## Known Issues
- Double smoothing (server EMA + iOS lerp) causes lag
- Env anchors and screen content can disagree, averaged result is wrong for both
- Optical flow scale_factor derived from homography det is imprecise
- Extra WiFi round-trip for /move commands adds latency

## Improvement Plan
1. Remove server-side EMA, smooth only on iOS
2. Prefer screen content exclusively when confident (>15 inliers)
3. Server moves cursor directly (skip /move round-trip)
4. Better optical flow scale from calibration geometry

# Global Design Canvas Design

## Goal

Render the entire Flutter application from one 800 x 1280 logical design canvas. The application must preserve its aspect ratio on every display, remain fully visible, and use centered letterboxing when the display is not 5:8.

## Current Problem

`DesignCanvas` is currently inserted by login pages and shared page shells. Page widgets are built above those wrappers, so calls such as `MediaQuery.sizeOf(context)` still observe the physical window size. Several pages then calculate their own scale before an outer `FittedBox` applies another scale. This makes the effective scale depend on the page and device size.

Route overlays also live above page-level canvases, so dialogs, snackbars, and other navigator content do not necessarily share the page transform.

## Architecture

`GetMaterialApp.builder` will install exactly one `DesignCanvas` above the Navigator. `DesignCanvas` will:

- expose an 800 x 1280 `MediaQuery` to all descendants;
- lay out its child at exactly 800 x 1280 logical pixels;
- use `BoxFit.contain` and centered alignment for one uniform render transform;
- fill unused screen space with the application background color.

Because routes are built below the root canvas, their existing `MediaQuery`-based layout calculations will receive the stable design size instead of the physical display size. Their reference-resolution appearance therefore remains unchanged while the outer canvas provides the only device-dependent scale.

## Component Changes

### DesignCanvas

`DesignCanvas` remains responsible only for the fixed logical viewport and device transform. It will define a reusable `Size(800, 1280)` constant and override descendant `MediaQuery` geometry for the fixed viewport.

System safe-area geometry will be zeroed inside the design viewport. This keeps the logical canvas deterministic; the full canvas is already fitted inside the available application window.

### Application Root

`getRootWidget` will provide a `GetMaterialApp.builder` that wraps its Navigator child with `DesignCanvas`. This places routes and Navigator overlays in the same coordinate system.

### Page Wrappers

The page-level `DesignCanvas` wrappers and their imports will be removed from:

- login, register, and forgotten-password pages;
- `AppHeaderPage`;
- `AppUsersHeaderPage`;
- `AppSettingHeaderPage`.

Their existing `Scaffold`, page content, and business behavior remain unchanged.

## Scaling Behavior

For a physical application window of `windowWidth x windowHeight`, the only device scale is:

```text
min(windowWidth / 800, windowHeight / 1280)
```

The transformed canvas is centered. A non-5:8 window receives horizontal or vertical letterboxing; no content is stretched or cropped.

## Testing

Widget tests will verify that:

- descendants of `DesignCanvas` observe an 800 x 1280 `MediaQuery`;
- a non-5:8 host centers the complete canvas with the expected uniform scale;
- the application Navigator is a descendant of the root `DesignCanvas`;
- representative routes contain exactly one `DesignCanvas`, preventing accidental nested scaling.

Focused widget tests will run first, followed by the existing Flutter test suite and static analysis. Existing unrelated failures, if any, will be reported separately rather than hidden by this change.

## Non-Goals

- Redesigning individual page layouts.
- Converting the application to fluid responsive layout.
- Cropping content to fill non-5:8 screens.
- Refactoring page business logic or unrelated media-query usage.

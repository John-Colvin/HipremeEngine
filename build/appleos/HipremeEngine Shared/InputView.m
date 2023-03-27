//
//  InputView.m
//  HipremeEngine
//
//  Created by Marcelo Silva  on 27/03/23.
//

#import <Foundation/Foundation.h>
#import "InputView.h"
#import "hipreme_engine.h"

@implementation InputView

- (instancetype) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    NSTrackingArea* ta = [[NSTrackingArea alloc] initWithRect:CGRectZero options:NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:ta];
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super mouseDown:event];
}
- (void)rightMouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super rightMouseDown:event];
}
- (void)otherMouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super otherMouseDown:event];
}
- (void)mouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super mouseUp:event];
}
- (void)rightMouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super rightMouseUp:event];
}
- (void)otherMouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super otherMouseUp:event];
}
- (void)mouseMoved:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super mouseMoved:event];
}
- (void)mouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super mouseDragged:event];
}
- (void)rightMouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super rightMouseDragged:event];
}
- (void)otherMouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super otherMouseDragged:event];
}

- (void)scrollWheel:(NSEvent *)event
{
    HipInputOnTouchScroll(event.deltaX, event.deltaY, event.deltaZ);
    [super scrollWheel:event];
}

- (void)keyDown:(NSEvent *)event
{
    HipInputOnKeyDown(event.keyCode);
    //[super keyDown:event];
}
- (void)keyUp:(NSEvent *)event
{
    HipInputOnKeyUp(event.keyCode);
    //[super keyUp:event];
}


-(float) getY:(int) y
{
    return self.bounds.size.height - y;
}

@end


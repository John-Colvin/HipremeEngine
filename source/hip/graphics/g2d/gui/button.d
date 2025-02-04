module hip.graphics.g2d.gui.button;
import hip.graphics.g2d.gui.inputarea;
import hip.math.collision;

/**
*   Responsible for controlling the input
*/
class HipButtonController
{
    int x, y, w, h;

    enum State{up,down,hovered}
    State state;

    void delegate() onClick;
    void delegate() onHover;
    void delegate() onUp;
    void delegate() onDown;

    void updateState(State forState, int x, int y)
    {
        if(isPointInRect(x, y, this.x, this.y, w, h))
            state = forState;
    }
}
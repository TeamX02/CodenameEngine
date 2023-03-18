package funkin.editors.ui;

import openfl.ui.Mouse;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class UIState extends MusicBeatState {
    public static var state(get, null):UIState;

    public var uiElements:Array<UISprite> = [];
    public var buttonHandler:Void->Void = null;

    private var __rect:FlxRect;
    private var __mousePos:FlxPoint;

    private inline static function get_state()
        return FlxG.state is UIState ? cast FlxG.state : null;

    public override function create() {
        __rect = new FlxRect();
        __mousePos = FlxPoint.get();
        super.create();

        memberAdded.add((basic:FlxBasic) -> {
            if (basic is UISprite) uiElements.push(cast basic);
            UIUtil.focusedUI = uiElements;
        });
    }

    public function updateButtonHandler(spr:UISprite, buttonHandler:Void->Void) {
        spr.__rect.x = spr.x;
        spr.__rect.y = spr.y;
        spr.__rect.width = spr.width;
        spr.__rect.height = spr.height;
        updateRectButtonHandler(spr, spr.__rect, buttonHandler);
    }

    public function updateRectButtonHandler(spr:UISprite, rect:FlxRect, buttonHandler:Void->Void) {
        FlxG.mouse.getScreenPosition(camera, __mousePos);
        
        for(camera in spr.__lastDrawCameras) {
            __rect.x = rect.x;
            __rect.y = rect.y;
            __rect.width = rect.width;
            __rect.height = rect.height;
            
            __rect.x -= camera.scroll.x * spr.scrollFactor.x;
            __rect.y -= camera.scroll.y * spr.scrollFactor.y;
            
            if (((__mousePos.x > __rect.x) && (__mousePos.x < __rect.x + rect.width)) && ((__mousePos.y > __rect.y) && (__mousePos.y < __rect.y + __rect.height))) {
                spr.hoveredByChild = true;
                this.buttonHandler = buttonHandler;
                return;
            }
        }
    }

    public override function tryUpdate(elapsed:Float) {
        super.tryUpdate(elapsed);

        if (buttonHandler != null) {
            buttonHandler();
            buttonHandler = null;
        }

        UIUtil.updateCursor();
    }

    public override function destroy() {
        super.destroy();
        __mousePos.put();
    }

    public function openContextMenu(options:Array<UIContextMenuOption>, ?x:Float, ?y:Float) {
        var state = FlxG.state;
        while(state.subState != null)
            state = state.subState;

        state.persistentDraw = true;
        state.persistentUpdate = true;

        openSubState(new UIContextMenu(options, x.getDefault(__mousePos.x), y.getDefault(__mousePos.y)));
    }
}
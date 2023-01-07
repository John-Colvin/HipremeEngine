/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.view.animationtestscene;

version(Test):
import hip.view.scene;
import hip.hiprenderer.viewport;
import hip.hiprenderer.renderer;
import hip.tween;
import hip.graphics.g2d.animation;
import hip.graphics.g2d.sprite;
import hip.graphics.g2d.spritebatch;
import hip.assets.texture;

class AnimationTestScene : Scene
{
    HipAnimation anim;
    HipSpriteBatch batch;
    HipSpriteAnimation spr;
    HipAnimationFrame frame;

    HipTween tween;
    this()
    {
        batch = new HipSpriteBatch();
        HipTexture t = new HipTexture("graphics/sprites/sprite.png");
        auto sheet = HipTextureRegion.cropSpritesheet(t, 32, 32, 96, 128);
        anim = new HipAnimation("Character");

        anim
            .addTrack(new HipAnimationTrack("walk_down", 12, true)
                .addFrames(sheet[0,0],
                            sheet[0,1],
                            sheet[0,2]
                ))
            .addTrack(new HipAnimationTrack("walk_left", 12, false)
                .addFrames(sheet[1,0],
                           sheet[1,1],
                           sheet[1,2]
            ))
            .addTrack(new HipAnimationTrack("walk_right", 12, true)
                .addFrames(HipAnimationFrame.fromTextureRegions(sheet, 2, 0, 2, 2)
                ))
            .addTrack(new HipAnimationTrack("walk_up", 12, false)
                .addFrames(sheet[3,0],
                           sheet[3,1],
                           sheet[3,2]
            ));

        spr = new HipSpriteAnimation(anim);
        spr.setAnimation("walk_right");

        tween = HipTween.to!(["x"])(15, spr, 400).play;
    }

    override void update(float dt)
    {
        tween.tick(dt);
        anim.update(dt);
        spr.setFrame(anim.getCurrentFrame());
        // import hip.console.log;
        // rawlog(tween.getProgress());
    }

    override void render()
    {
        super.render();
        Viewport v = HipRenderer.getCurrentViewport();
        v.updateForWindowSize(800, 600);
        HipRenderer.setViewport(v);
        batch.camera.setScale(2, 2);
        batch.draw(spr);
        batch.render();
    }
}
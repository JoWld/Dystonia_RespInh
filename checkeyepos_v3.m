function [outcome,xxx,yyy]=checkeyepos_v3(tracking_window,xRes,yRes,fixXpos,fixYpos,FixdotColor,showwin,eye_used)
persistent lasttime
if isempty(lasttime)
    lasttime=GetSecs;
end
outcome=0;
samplepresent=0;
win_act=tracking_window;

while samplepresent==0
    if Eyelink('NewFloatSampleAvailable') > 0
        samplepresent=1;
        sample = Eyelink('NewestFloatSample');
        if eye_used ~=-1
            xxx=sample.gx(eye_used+1);
            yyy=sample.gy(eye_used+1);
            if xxx<win_act(1)||xxx>win_act(2)||yyy<win_act(3)||yyy>win_act(4)
                outcome=0;
                wincol='-r';
            else
                outcome=1;
                wincol='-g';
            end
        if GetSecs-lasttime>0.03
            lasttime=GetSecs;
            figure(4)
            if showwin==1
                plot([win_act(1) win_act(1) win_act(2) win_act(2) win_act(1)],[win_act(3) win_act(4) win_act(4) win_act(3) win_act(3)],wincol)
                hold on
            end
            t=plot(fixXpos,fixYpos,'.');
            set(t,'Color',FixdotColor/255,'MarkerSize',20)
            plot(xxx,yyy,'xk')
            set(gca,'YDir','reverse');
            axis([0 xRes 0 yRes])
            hold off
            drawnow
        end
        end
    end
end
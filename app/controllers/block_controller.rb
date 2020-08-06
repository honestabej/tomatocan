class BlockController < ApplicationController
    def load
        # ActionCable.server.broadcast "viewer_channel", content: {user: params[:user], room: params[:room], owner: params[:owner]}
        ActionCable.server.broadcast "viewer_channel", content: {message: params[:message], user: params[:user]}
        head :ok
    end
              
    def inViewer
        current_user = User.find_by_id(params[:user])
        current_user.update_column(:last_viewed, current_user.last_viewed << params[:room])
        head :ok
    end

    def block
        # get person to block and owner of convo
        to_block = User.find_by_id(params[:to_block])
        owner = User.find_by_id(params[:owner])

        # get blockedBy array and BlockedUsers array
        array = to_block.blockedBy
        array2 = owner.BlockedUsers

        # check if user has already been blocked
        unless array2.include? (to_block.permalink)
            to_block.update({'blockedBy': array << owner.permalink})        # add owner of convo to blockedBy array
            owner.update({'BlockedUsers': array2 << to_block.permalink})    # add user to be blocked to owner's BlockedUsers array
        end
        
        # return 200 ok
        head :ok
    end

    def unblock
        # get to_unblock user and current_user
        to_unblock = User.find_by_id(params[:to_unblock_id])
        current_user = User.find_by_id(params[:current_user_id])

        # get blocked by array
        array = to_unblock.blockedBy

        # remove current_user from blockedBy array
        array = array - [current_user.permalink]
        to_unblock.update({'blockedBy': array})
        
        # get blockedUsers array
        array = current_user.BlockedUsers

        # remove to_unblock from blockedUsers array
        array = array - [to_unblock.permalink]
        current_user.update({'BlockedUsers': array})

        # return 200 ok
        head :ok
    end

    def unload
        # gets the current user
        current_user = User.find_by_id(params[:user])

        # remove the current event from user's last_viewed array
        array = current_user.last_viewed
        array = array - [params[:room]]
        current_user.update({'last_viewed': array})
        
        # return 200 ok
        head :ok
    end

    def is_blocked
        render plain: current_user.blockedBy, content_type: 'text/plain'
    end

    def loadAttendees
        # return attendees layout
        render :json => {:success => true, :html => (render_to_string partial: "layouts/attendees")}
    end

    def liveCount
        # return live_count layout
        render :json => {:success => true, :html => (render_to_string partial: "layouts/live_count")}
    end
end

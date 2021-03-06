require 'spec_helper'

describe Comment do
  let(:user_1) { create_user! }
  let(:user_2) { create_user! }
  let(:user_3) { create_user! }

  before do
    # First, we need to create a book and a note for some place in the book
    create_book!
    chapter = @book.chapters.first
    @note = chapter.notes.create!(:text => "This is a test note!", 
                                               :user => user_1, 
                                               :number => 1,
                                               :element => chapter.elements.first,
                                               :state => "complete")
    # Create a comment
    @note.comments.create!(:user => user_2, :text => "FIRST POST!")
    reset_mailer
  end

  context "upon creation" do
    it "sends an email to note author + commentors, minus comment owner" do
      comment = @note.comments.create!(:user => user_3, :text => "Second post")
      comment.send_notifications!

      email_1 = find_email(user_1.email)
      email_2 = find_email(user_2.email)

      email_1.subject.should == "[Twist] - Rails 3 in Action - Note #1"
      email_2.subject.should == "[Twist] - Rails 3 in Action - Note #1"
    end

    it "sends notification emails to the right users" do
      comment = @note.comments.build(:user => user_3)
      emails = comment.notification_emails
      emails.should include(user_1.email)
      emails.should include(user_2.email)
      emails.should_not include(user_3.email)
    end
  end
end

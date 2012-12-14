# == Schema Information
#
# Table name: articles
#
#  id         :integer          not null, primary key
#  body       :text
#  subtitle   :string(255)
#  section    :string(255)
#  teaser     :string(255)
#  title      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

require 'taxonomy'


describe Article do

  before do
    @article = Article.new(title: 'Ash defeats Gary in Indigo Plateau',
                           subtitle: 'Oak arrives just in time',
                           teaser: 'Ash becomes new Pokemon champion',
                           body: '**Pikachu** wrecks everyone. The End.',
                           section: '/news/',
                           )
  end

  subject { @article }

  it { should be_valid }

  describe "when body is not present" do
    before { @article.body = "" }
    it { should_not be_valid }
  end

  describe "when title is not present" do
    before { @article.title = "" }
    it { should_not be_valid }
  end

  describe "#section" do
    it { @article.section.should be_a_kind_of(Taxonomy) }
    it do
      taxonomy = Taxonomy.new(['News', 'University'])
      @article.section = taxonomy
      @article.section.should == taxonomy
    end
  end

  describe "#render_body" do
    it "should render the article body with markdown" do
      html = '<p><strong>Pikachu</strong> wrecks everyone. The End.</p>'
      @article.render_body.should == html
    end
  end

  describe "#normalize_friendly_id" do
    subject { @article.normalize_friendly_id(@article.title) }

    it "should be lowercased" do
      should match(/[a-z_\d\-]+/)
    end

    it "should contain key words of title" do
      should include('ash')
      should include('defeats')
      should include('gary')
      should include('indigo')
      should include('plateau')
    end

    it "should not have unnecessary words" do
      should_not include('-in-')
    end

    context "long title" do
      subject { @article.normalize_friendly_id('a' * 99 + '-' + 'b' * 100) }
      it { should have_at_most(100).characters }
      it { should_not match(/\-$/) }
    end
  end
end
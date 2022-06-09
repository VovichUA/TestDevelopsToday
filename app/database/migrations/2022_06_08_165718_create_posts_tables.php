<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePostsTables extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {

        Schema::table('users', static function (Blueprint $table) {
            $table->tinyInteger('role')->default(1);
        });

        Schema::create('posts', static function (Blueprint $table) {
            $table->id();
            $table->string('title', 100);
            $table->text('body');
            $table->string('link');
            $table->unsignedBigInteger('user_id');
            $table->timestamps();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();
        });

        Schema::create('votes', static function (Blueprint $table) {
            $table->id();
            $table->boolean('vote');
            $table->unsignedBigInteger('post_id');

            $table->foreign('post_id')
                ->references('id')
                ->on('posts')
                ->cascadeOnDelete();
        });

        Schema::create('user_votes', static function (Blueprint $table) {
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('vote_id');

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();

            $table->foreign('vote_id')
                ->references('id')
                ->on('votes')
                ->cascadeOnDelete();
        });

        Schema::create('comments', static function (Blueprint $table) {
            $table->id();
            $table->string('comment');
            $table->unsignedBigInteger('user_id');
            $table->timestamps();

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::disableForeignKeyConstraints();

        Schema::dropIfExists('comments');
        Schema::dropIfExists('user_votes');
        Schema::dropIfExists('votes');
        Schema::dropIfExists('posts');
        Schema::table('users', static function (Blueprint $table) {
            $table->dropColumn('role');
        });
    }
}

<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateBrokersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('brokers', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->text('image');
            $table->string('mindiposit')->nullable();
            $table->string('minspread')->nullable();
            $table->string('maxleverage')->nullable();
            $table->string('dipositbonus')->nullable();
            $table->string('welbonus')->nullable();
            $table->string('currencypairs')->nullable();
            $table->string('increments')->nullable();
            $table->string('platforms')->nullable();
            $table->string('typebroker')->nullable();
            $table->string('regulatedby')->nullable();
            $table->string('established')->nullable();
            $table->string('headquater')->nullable();
            $table->string('reviewlink')->nullable();
            $table->string('visitlink')->nullable();
            $table->tinyInteger('status');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('brokers');
    }
}

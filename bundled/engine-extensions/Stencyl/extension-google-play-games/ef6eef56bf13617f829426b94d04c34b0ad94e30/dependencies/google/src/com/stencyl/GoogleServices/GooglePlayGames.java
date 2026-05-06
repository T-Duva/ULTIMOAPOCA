package com.stencyl.GoogleServices;

import org.haxe.extension.Extension;
import org.haxe.lime.HaxeObject;

import android.content.Intent;
import android.util.Log;

import com.google.android.gms.games.*;
import com.google.example.games.basegameutils.GameHelper;
import com.google.example.games.basegameutils.GameHelper.GameHelperListener;

public class GooglePlayGames extends Extension
{
    static GameHelper mHelper;
    static GooglePlayGames mpg = null;
    static HaxeObject haxeCallback;
    
    public GooglePlayGames()
    {
        super();
        
        mpg = this;
    }
    
    static public void initGooglePlayGames(final HaxeObject obj)
    {
        Log.d("GPG", "Initialiazing Google Play Games (Java)");        
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                haxeCallback = obj;
                if (mHelper == null){
                
                    mHelper = new GameHelper(mainActivity, GameHelper.CLIENT_GAMES);
                    
                    GameHelperListener listener = new GameHelper.GameHelperListener() {
                        @Override
                        public void onSignInSucceeded() {
                            // handle sign-in succeess
                            Log.d("GPG", "onSignInSucceeded");
                        }
                        @Override
                        public void onSignInFailed() {
                            // handle sign-in failure (e.g. show Sign In button)
                            Log.d("GPG", "onSignInFailed");
                            Log.d("GPG", "user cancelled: " + mHelper.hasUserCancellation());
                            
                            if (mHelper.getSignInError() != null)
                            {
                                String serviceErrorCode = String.valueOf(mHelper.getSignInError().getServiceErrorCode());
                                // https://developers.google.com/android/reference/com/google/android/gms/common/ConnectionResult
                                
                                String activityResultCode = String.valueOf(mHelper.getSignInError().getActivityResultCode());
                                // https://developers.google.com/android/reference/com/google/android/gms/games/GamesActivityResultCodes
                                
                                String errorText = new String("GPG sign in failed (service error code: " + serviceErrorCode + ", activity result code: " + activityResultCode + ").");
                                haxeCallback.call("onSignInFailed", new Object[] {errorText});
                            }
                        }
                        
                    };
                    mHelper.setup(listener);
                }
                                
                mHelper.beginUserInitiatedSignIn();
            }
        });
    }
    
    static public void signOutGooglePlayGames()
    {
        Log.d("GPG", "Signing out from Google Play Games (Java)");
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                 if (mHelper != null && mHelper.isSignedIn())
                {
                    mHelper.signOut();
                }
            }
        });
    }
    
    static public boolean isSignedIn()
    {
        if (mHelper != null && mHelper.isSignedIn())
        {
            return true;
        }
        else return false;
    }
    
    static public boolean isConnecting()
    {
        if (mHelper != null && mHelper.isConnecting())
        {
            return true;
        }
        else return false;
    }
    
    static public boolean hasSignInError()
    {
        if (mHelper != null && mHelper.hasSignInError())
        {
            return true;
        }
        else return false;
    }
    
    static public boolean hasUserCancellation()
    {
        
        if (mHelper != null && mHelper.hasUserCancellation())
        {
            return true;
        }
        else return false;
    }   
    
    static public void showAchievements()
    {
        Log.d("GPG", "Showing Achievements (Java 1)");
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null && mHelper.isSignedIn())
                {
                    Log.d("GPG", "Showing Achievements (Java 2)");
                    mainActivity.startActivityForResult(Games.Achievements.getAchievementsIntent(mHelper.getApiClient()), 1);
                }
            }
        });
    }
    
    static public void unlockAchievement(String id)
    {
        Log.d("GPG", "Unlocking Achievement " + id + " (Java)");        
        
        if (mHelper != null && mHelper.isSignedIn())
        {
            Games.Achievements.unlock(mHelper.getApiClient(), id);
        }
    }
    
    static public void incrementAchievement(String id, int numSteps)
    {
        Log.d("GPG", "Incrementing Achievement " + id + " (Java 1)");
        
        if (mHelper != null && mHelper.isSignedIn())
        {
                Log.d("GPG", "Incrementing Achievement " + id + " (Java 2)");
                Games.Achievements.increment(mHelper.getApiClient(), id, numSteps);
        }
            
    }
    
    static public void unlockAchievementImmediate(String id)
    {
        Log.d("GPG", "Unlocking Achievement Immediate: " + id + " (Java)");        
        
        if (mHelper != null && mHelper.isSignedIn())
        {
            Games.Achievements.unlockImmediate(mHelper.getApiClient(), id);
        }
    }
    
    static public void incrementAchievementImmediate(String id, int numSteps)
    {
        Log.d("GPG", "Incrementing Achievement Immediate: " + id + " (Java 1)");
        
        if (mHelper != null && mHelper.isSignedIn())
        {
                Games.Achievements.incrementImmediate(mHelper.getApiClient(), id, numSteps);
        }
            
    }
    
    static public void showAllLeaderboards()
    {
        Log.d("GPG", "Showing Leaderboards (Java 1)");
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null && mHelper.isSignedIn())
                {
                    Log.d("GPG", "Showing All Leaderboards (Java 2)");
                    mainActivity.startActivityForResult(Games.Leaderboards.getAllLeaderboardsIntent(mHelper.getApiClient()), 1);
                }
            }
        });
    }
    
    
    
    static public void showLeaderboard(final String id)
    {
        Log.d("GPG", "Showing Leaderboards (Java 1)");
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null && mHelper.isSignedIn())
                {
                    Log.d("GPG", "Showing Leaderboards (Java 2)");
                    mainActivity.startActivityForResult(Games.Leaderboards.getLeaderboardIntent(mHelper.getApiClient(), id), 1);
                }
            }
        });
    }
    
    static public void submitScore(String id, int score)
    {
        Log.d("GPG", "Submitting Score " + score + " to " + id + " (Java 1)");
        
        if (mHelper != null && mHelper.isSignedIn())
        {
            Log.d("GPG", "Submitting Score " + score + " to " + id + " (Java 2)");
            Games.Leaderboards.submitScore(mHelper.getApiClient(), id, score);
        }
            
    }
    
    static public void updateEvent(String id, int amount)
    {
        Log.d("GPG", "Updating Event " + id + " by " + amount + " (Java 1)");
        
        if (mHelper != null && mHelper.isSignedIn())
        {
            Log.d("GPG", "Updating Event " + id + " by " + amount + " (Java 2)");
            Games.Events.increment(mHelper.getApiClient(), id, amount);
        }            
    }
    
    public void onStart()
    {
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null)
                {
                    mHelper.onStart(mainActivity);
                }
            }
        });
    }
    
    public void onStop()
    {
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null)
                {
                    mHelper.onStop();
                }
            }
        });
    }
    
    public boolean onActivityResult(int request, int response, Intent data)
    {
        final int req = request;
        final int res = response;
        final Intent dat = data;
        
        mainActivity.runOnUiThread(new Runnable()
        {
            public void run()
            {
                if (mHelper != null)
                {
                    mHelper.onActivityResult(req, res, dat);
                }
            }
        });
        
        return true;
    }
}